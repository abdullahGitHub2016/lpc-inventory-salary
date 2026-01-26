<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SalaryArchiveSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
{
    $months = [
        ['name' => 'October', 'num' => 10],
        ['name' => 'September', 'num' => 9],
        ['name' => 'August', 'num' => 8],
    ];

    foreach ($months as $m) {
        $sheetId = DB::table('salary_sheets')->insertGetId([
            'month' => $m['name'],
            'month_number' => $m['num'],
            'year' => 2025,
            'total_payout' => 50000,
            'created_at' => now(),
        ]);

        DB::table('salary_sheet_details')->insert([
            'salary_sheet_id' => $sheetId,
            'employee_id' => 'LPC-TEST',
            'name' => 'Sample Employee',
            'base_salary' => 60000,
            'advance' => 10000,
            'net_payable' => 50000,
        ]);
    }
}
}
