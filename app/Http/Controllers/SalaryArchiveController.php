<?php

namespace App\Http\Controllers;

use App\Models\Employee;
use App\Models\SalaryAdvance;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;

class SalaryArchiveController extends Controller
{
    /**
     * Display the Archive Grid (SalaryArchiveIndex.vue)
     */
    // app/Http/Controllers/SalaryArchiveController.php

    public function index(Request $request)
    {
        // Get the selected year or default to the current year
        $year = $request->input('year', date('Y'));

        // Fetch unique years from the database to populate the dropdown
        $availableYears = DB::table('salary_sheets')
            ->select('year')
            ->distinct()
            ->orderBy('year', 'desc')
            ->pluck('year');

        $history = DB::table('salary_sheets')
            ->where('year', $year)
            ->orderBy('month_number', 'desc')
            ->get();

        return Inertia::render('Salary/SalaryArchiveIndex', [
            'history' => $history,
            'availableYears' => $availableYears, // Send the real years list
            'filters' => [
                'year' => (int)$year
            ]
        ]);
    }

    /**
     * Display a specific month (SalaryArchiveShow.vue)
     */
    public function show(Request $request)
    {
        $month = $request->month;
        $year = $request->year;

        // Fetch the finalized snapshot for that month
        // We include the employees and their specific balances at that time
        $monthData = DB::table('salary_sheets')
            ->where('month', $month)
            ->where('year', $year)
            ->first();

        if (!$monthData) {
            return redirect()->route('salary.archive.index')->with('error', 'Record not found.');
        }

        // Get the employee records that were saved for this specific sheet
        $employees = DB::table('salary_sheet_details')
            ->where('salary_sheet_id', $monthData->id)
            ->get();

        return Inertia::render('Salary/SalaryArchiveShow', [
            'monthData' => [
                'id' => $monthData->id,
                'month' => $monthData->month,
                'year' => $monthData->year,
                'employees' => $employees
            ]
        ]);
    }
}
