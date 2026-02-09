<?php

namespace App\Http\Controllers;

use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class EmployeeController extends Controller
{
    /**
     * Display a listing of employees (Agile User Story 1 & 7)
     */
    public function index(Request $request)
{
    $employees = Employee::query()
        // This ensures the newest IDs (highest numbers) come first
        ->latest()
        ->when($request->search, function ($query, $search) {
            $query->where('name', 'like', "%{$search}%")
                  ->orWhere('employee_id', 'like', "%{$search}%");
        })
        ->paginate(10)
        ->withQueryString();

    return Inertia::render('SalaryIndex', [
        'employees' => $employees,
        'filters' => $request->only(['search'])
    ]);
}
    /**
     * Store a newly created employee (The "Main Element" entry)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'employee_id' => 'required|string|unique:employees,employee_id',
            'name'        => 'required|string|max:255',
            'designation' => 'nullable|string|max:255', // Validate designation
            'base_salary' => 'required|numeric',
        ]);

        \App\Models\Employee::create([
            'employee_id'  => $validated['employee_id'],
            'name'         => $validated['name'],
            'designation'  => $validated['designation'],
            'total_salary' => $validated['base_salary'], // Map form field to DB column
        ]);

        return back();
    }

    public function update(Request $request, $id)
    {
        $employee = \App\Models\Employee::findOrFail($id);
        $validated = $request->validate([
            'employee_id' => 'required|string|unique:employees,employee_id,' . $id,
            'name'        => 'required|string|max:255',
            'designation' => 'nullable|string|max:255', // Validate designation
            'base_salary' => 'required|numeric',
        ]);

        $employee->update([
            'employee_id'  => $validated['employee_id'],
            'name'         => $validated['name'],
            'designation'  => $validated['designation'],
            'total_salary' => $validated['base_salary'], // Map form field to DB column
        ]);

        return back();
    }
    /**
     * Remove the employee (Data Hygiene)
     */
    public function destroy(Employee $employee)
    {
        // Check if employee has history in archives before deleting
        $hasHistory = DB::table('salary_sheet_details')
            ->where('employee_id', $employee->employee_id)
            ->exists();

        if ($hasHistory) {
            return back()->with('error', 'Cannot delete employee with existing payroll history. Deactivate them instead.');
        }

        $employee->delete();
        return back()->with('success', 'Employee removed from system.');
    }
}
