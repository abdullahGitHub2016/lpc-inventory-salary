<?php

namespace App\Http\Controllers;

use \App\Models\AdvanceReason;
use App\Models\Employee;
use App\Models\Leave;
use App\Models\SalaryAdvance;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class SalaryController extends Controller
{
    // app/Http/Controllers/SalaryController.php

public function index(Request $request)
{
    // 1. Initialize query with relationships
    $query = Employee::query();

    // 2. Search by Name or Employee ID
    if ($request->filled('search')) {
        $search = $request->search;
        $query->where(function($q) use ($search) {
            $q->where('name', 'like', '%' . $search . '%')
              ->orWhere('employee_id', 'like', '%' . $search . '%');
        });
    }

    // 3. Paginate the results (e.g., 10 per page)
    $employees = $query->paginate(3)->withQueryString()->through(function ($employee) {
        $history = $employee->advances()
            ->with('reason')
            ->orderBy('advance_date', 'desc')
            ->get();

        return [
            'id'            => $employee->id,
            'employee_id'   => $employee->employee_id,
            'name'          => $employee->name,
            'base_salary'   => (float) $employee->total_salary,
            'advance'       => (float) $history->where('status', 'pending')->sum('amount'),
            'net_payable'   => (float) ($employee->total_salary - $history->where('status', 'pending')->sum('amount')),
            'advance_history' => $history
        ];
    });

    return Inertia::render('Salary/SalaryIndex', [
        'employees'      => $employees, // Now a paginated object
        'advanceReasons' => \App\Models\AdvanceReason::all(),
        'filters'        => $request->only(['search'])
    ]);
}
    /**
     * Store the advance taken by an employee
     */
    public function storeAdvance(Request $request)
    {
        $request->validate([
            'employee_id' => 'required|exists:employees,id',
            'reason_id'   => 'required|exists:advance_reasons,id',
            'amount'      => 'required|numeric|min:1',
        ]);

        SalaryAdvance::create([
            'employee_id'  => $request->employee_id,
            'reason_id'    => $request->reason_id,
            'amount'       => $request->amount,
            'advance_date' => now(),
            'status'       => 'pending',
        ]);

        return redirect()->back()->with('message', 'Advance added successfully!');
    }

    /**
     * Logic to show the Final Salary after deductions
     */
    public function getSalarySheet()
    {
        $employees = Employee::all()->map(function ($employee) {
            // Calculate total pending advances
            $totalAdvance = SalaryAdvance::where('employee_id', $employee->id)
                ->where('status', 'pending')
                ->sum('amount');

            return [
                'name' => $employee->name,
                'base_salary' => $employee->total_salary,
                'advance_deduction' => $totalAdvance,
                'net_salary' => $employee->total_salary - $totalAdvance,
                'advance_details' => SalaryAdvance::where('employee_id', $employee->id)
                    ->where('status', 'pending')
                    ->get(['reason', 'amount'])
            ];
        });

        return Inertia::render('Salary/Sheet', ['salaryData' => $employees]);
    }

    public function processAttendance($employeeId, $returnDate)
    {
        $leave = Leave::where('employee_id', $employeeId)
            ->where('status', 'Approved')
            ->latest()
            ->first();

        // Logic: If they were supposed to return on Day 4 but joined on Day 5
        if ($returnDate > $leave->expected_return_date) {
            $leave->update([
                'status' => 'Cancelled',
                'remarks' => 'Returned late: Leave converted to absent/unpaid'
            ]);

            // This will now trigger a full salary deduction for those days
        }
    }
    public function recordReturn(Request $request)
    {
        $leave = Leave::where('employee_id', $request->employee_id)
            ->where('status', 'Approved')
            ->latest()
            ->first();

        if ($leave) {
            $actualReturn = $request->return_date; // e.g., 5th day

            if ($actualReturn > $leave->expected_return_date) {
                // Logic: 3 days leave, expected back on 4th, came on 5th = CANCEL
                $leave->update([
                    'status' => 'Cancelled',
                    'actual_return_date' => $actualReturn,
                    'remarks' => 'Leave cancelled: Late return'
                ]);
            } else {
                $leave->update(['status' => 'Completed', 'actual_return_date' => $actualReturn]);
            }
        }
    }
    public function markAttendance(Request $request)
    {
        $today = now()->format('Y-m-d');

        // Find if the employee had an active approved leave
        $leave = Leave::where('employee_id', $request->employee_id)
            ->where('status', 'Approved')
            ->first();

        if ($leave) {
            // If today is past the expected return date and they are just showing up now
            if ($today > $leave->expected_return_date) {
                $leave->update(['status' => 'Cancelled']);
                // Logic: Because it's cancelled, the payroll will now treat those days as Unpaid
            } else {
                $leave->update(['status' => 'Completed']);
            }
        }
    }

    public function processReturn(Request $request)
    {
        $today = now()->format('Y-m-d');

        $leave = Leave::where('employee_id', $request->employee_id)
            ->where('status', 'Approved')
            ->latest()
            ->first();

        if ($leave) {
            // Logic: Today is 5th, Expected was 4th
            if ($today > $leave->expected_return_date) {
                $leave->update(['status' => 'Cancelled']);
                // When calculating salary, cancelled leave days = $0 pay.
                return "Late return detected. Leave has been cancelled.";
            } else {
                $leave->update(['status' => 'Completed']);
                return "Employee returned on time.";
            }
        }
    }
    public function processMonthly(Request $request)
{
    // 1. Prepare Month/Year info
    $now = Carbon::now();
    $monthName = $now->format('F');
    $year = $now->year;
    $monthNumber = $now->month;

    // Prevent double processing if the month is already archived
    $exists = DB::table('salary_sheets')
        ->where('month', $monthName)
        ->where('year', $year)
        ->exists();

    if ($exists) {
        return back()->with('error', "The salary for $monthName $year has already been processed.");
    }

    DB::beginTransaction();
    try {
        // 2. Get all employees with their current live balances
        // This logic must match exactly how you display it on the Live Dashboard
        $employees = Employee::all()->map(function($emp) {
            $totalAdvance = SalaryAdvance::where('employee_id', $emp->id)
                            ->whereMonth('advance_date', Carbon::now()->month)
                            ->sum('amount');

            return [
                'employee_id_string' => $emp->employee_id, // e.g. "LPC-001"
                'name' => $emp->name,
                'base_salary' => $emp->base_salary,
                'advance' => $totalAdvance,
                'net_payable' => $emp->base_salary - $totalAdvance,
            ];
        });

        $totalPayout = $employees->sum('net_payable');

        // 3. Create the Archive Header
        $salarySheetId = DB::table('salary_sheets')->insertGetId([
            'month' => $monthName,
            'month_number' => $monthNumber,
            'year' => $year,
            'total_payout' => $totalPayout,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // 4. Save snapshots of every employee
        foreach ($employees as $data) {
            DB::table('salary_sheet_details')->insert([
                'salary_sheet_id' => $salarySheetId,
                'employee_id' => $data['employee_id_string'],
                'name' => $data['name'],
                'base_salary' => $data['base_salary'],
                'advance' => $data['advance'],
                'net_payable' => $data['net_payable'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // 5. RESET THE LIVE LEDGER
        // Delete or mark current month advances as 'processed'
        // This clears the "Advance" column on your Live Dashboard for next month
        SalaryAdvance::whereMonth('advance_date', $monthNumber)
                     ->whereYear('advance_date', $year)
                     ->delete();

        DB::commit();
        return redirect()->route('salary.archive.index')->with('success', "Salary for $monthName processed and archived successfully.");

    } catch (\Exception $e) {
        DB::rollback();
        return back()->with('error', 'Error processing salary: ' . $e->getMessage());
    }
}
}
