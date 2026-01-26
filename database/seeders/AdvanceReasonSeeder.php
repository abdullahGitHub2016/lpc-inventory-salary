<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AdvanceReasonSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
{
    $reasons = ['Medical Emergency', 'Family Needs', 'Education', 'House Rent', 'Travel'];
    foreach ($reasons as $reason) {
        \App\Models\AdvanceReason::create(['reason_name' => $reason]);
    }
}
}
