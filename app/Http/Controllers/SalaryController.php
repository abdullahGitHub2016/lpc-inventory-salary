<?php

namespace App\Http\Controllers;

use \App\Models\AdvanceReason;
use App\Models\Employee;
use App\Models\Leave;
use App\Models\SalaryAdvance;
use Illuminate\Http\Request;
use Inertia\Inertia;

class SalaryController extends Controller
{
    public function index(Request $request)
    {
        // 1. Start the query with the advances relationship
        $query = Employee::with(['advances']);

        // 2. Filter by Employee ID (the string version like EMP-001)
        if ($request->filled('search_id')) {
            $query->where('employee_id', 'like', '%' . $request->search_id . '%');
        }

        $employees = $query->get()->map(function ($employee) {
            // Get all advances, sorted by date
            $history = $employee->advances()
                ->with('reason') // Load the reason relationship
                ->orderBy('advance_date', 'desc')
                ->get();

            return [
                'id'            => $employee->id,
                'employee_id'   => $employee->employee_id,
                'name'          => $employee->name,
                'base_salary'   => (float) $employee->total_salary,
                'advance'       => (float) $history->where('status', 'pending')->sum('amount'),
                'net_payable'   => (float) ($employee->total_salary - $history->where('status', 'pending')->sum('amount')),
                // This is the history array for the modal
                'advance_history' => $history
            ];
        });

        return Inertia::render('Salary/Index', [
            'employees'      => $employees,
            'advanceReasons' => \App\Models\AdvanceReason::all(),
            'filters'        => (object) $request->only(['search_id', 'date'])
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
}
