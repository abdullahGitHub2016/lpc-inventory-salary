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
        $query = Employee::query()->latest();

        // 2. Search by Name or Employee ID
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                    ->orWhere('employee_id', 'like', '%' . $search . '%');
            });
        }

        // 3. Paginate the results (e.g., 10 per page)
        $employees = $query->paginate(10)->withQueryString()->through(function ($employee) {
            $history = $employee->advances()
                ->with('reason')
                ->orderBy('advance_date', 'desc')
                ->get();

            return [
                'id'            => $employee->id,
                'employee_id'   => $employee->employee_id,
                'designation'   => $employee->designation,
                'name'   => $employee->name,
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

    // app/Http/Controllers/SalaryController.php

    public function processMonthly(Request $request)
    {
        // Use Carbon to get current timing so payload isn't needed
        $now = \Carbon\Carbon::now();
        $monthName = $now->format('F');
        $monthNumber = $now->month;
        $year = $now->year;

        // Check if archive already exists for this specific month/year
        $alreadyExists = DB::table('salary_sheets')
            ->where('month', $monthName)
            ->where('year', $year)
            ->exists();

        if ($alreadyExists) {
            return back()->with('error', "Payroll for $monthName $year is already closed.");
        }

        DB::beginTransaction();
        try {
            // Fetch ALL employees from the database
            $employees = \App\Models\Employee::all();

            if ($employees->isEmpty()) {
                return back()->with('error', 'No employees found to process.');
            }

            $grandTotalPayout = 0;

            // 1. Insert the Header
            $salarySheetId = DB::table('salary_sheets')->insertGetId([
                'month' => $monthName,
                'month_number' => $monthNumber,
                'year' => $year,
                'total_payout' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // 2. Process each employee
            foreach ($employees as $emp) {
                // 1. Get the sum of advances
                $advanceSum = DB::table('salary_advances')
                    ->where('employee_id', $emp->id)
                    ->whereMonth('advance_date', $monthNumber)
                    ->whereYear('advance_date', $year)
                    ->sum('amount') ?? 0;

                // 2. Ensure base_salary is a number (FIXES THE NULL ERROR)
                $baseSalary = $emp->base_salary ?? 0;

                // 3. Calculate net payable
                $netPayable = $baseSalary - $advanceSum;
                $grandTotalPayout += $netPayable;

                // 4. Insert into details
                DB::table('salary_sheet_details')->insert([
                    'salary_sheet_id' => $salarySheetId,
                    'employee_id'     => $emp->employee_id,
                    'name'            => $emp->name,
                    'base_salary'     => $baseSalary, // Now this will be 0 instead of NULL
                    'advance'         => $advanceSum,
                    'net_payable'     => $netPayable,
                    'created_at'      => now(),
                    'updated_at'      => now(),
                ]);
            }

            // 4. Update Header Total
            DB::table('salary_sheets')->where('id', $salarySheetId)->update([
                'total_payout' => $grandTotalPayout
            ]);

            // 5. CLEAR live advances for the processed month
            DB::table('salary_advances')
                ->whereMonth('advance_date', $monthNumber)
                ->whereYear('advance_date', $year)
                ->delete();

            DB::commit();

            return redirect()->route('salary.archive.index')
                ->with('success', "Payroll for $monthName $year has been archived.");
        } catch (\Exception $e) {
            dd($e);
            DB::rollback();
            return back()->with('error', 'Server Error: ' . $e->getMessage());
        }
    }
    // app/Http/Controllers/SalaryController.php

    public function destroyArchive($month, $year)
    {
        DB::beginTransaction();
        try {
            $archive = DB::table('salary_sheets')
                ->where('month', $month)
                ->where('year', $year)
                ->first();

            if ($archive) {
                // Delete snapshots first due to foreign key constraints
                DB::table('salary_sheet_details')->where('salary_sheet_id', $archive->id)->delete();
                DB::table('salary_sheets')->where('id', $archive->id)->delete();

                DB::commit();
                return redirect()->back()->with('success', 'Archive deleted.');
            }
            return back()->with('error', 'Not found.');
        } catch (\Exception $e) {
            DB::rollback();
            return back()->with('error', 'Failed: ' . $e->getMessage());
        }
    }
    // app/Http/Controllers/SalaryController.php

    public function rollbackArchive($month, $year)
    {
        DB::beginTransaction();
        try {
            $archive = DB::table('salary_sheets')
                ->where('month', $month)
                ->where('year', $year)
                ->first();

            if (!$archive) return back()->with('error', 'Archive not found.');

            $details = DB::table('salary_sheet_details')
                ->where('salary_sheet_id', $archive->id)
                ->get();

            foreach ($details as $row) {
                if ($row->advance > 0) {
                    // Find internal ID based on the string ID stored in details
                    $internalEmpId = DB::table('employees')
                        ->where('employee_id', $row->employee_id)
                        ->value('id');

                    if ($internalEmpId) {
                        DB::table('salary_advances')->insert([
                            'employee_id' => $internalEmpId,
                            'reason_id'   => 1, // Assumes 1 is a default reason
                            'amount'      => $row->advance,
                            'advance_date' => now(), // Moves to current date for the live ledger
                            'created_at'  => now(),
                            'updated_at'  => now(),
                        ]);
                    }
                }
            }

            // Clean up archive tables
            DB::table('salary_sheet_details')->where('salary_sheet_id', $archive->id)->delete();
            DB::table('salary_sheets')->where('id', $archive->id)->delete();

            DB::commit();
            return redirect()->route('salary.index')->with('success', 'Month reopened for editing.');
        } catch (\Exception $e) {
            DB::rollback();
            return back()->with('error', 'Rollback failed: ' . $e->getMessage());
        }
    }
    // Helper to convert LPC-001 back to internal primary key
    private function getInternalId($empStringId)
    {
        return DB::table('employees')->where('employee_id', $empStringId)->value('id');
    }
}
