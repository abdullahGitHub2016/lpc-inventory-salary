<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        // 1. The Header (The Month/Year)
        Schema::create('salary_sheets', function (Blueprint $table) {
            $table->id();
            $table->string('month');       // e.g., "December"
            $table->integer('month_number'); // e.g., 12 (for sorting)
            $table->integer('year');        // e.g., 2025
            $table->decimal('total_payout', 15, 2);
            $table->timestamps();
        });

        // 2. The Details (The Employees for that month)
        Schema::create('salary_sheet_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salary_sheet_id')->constrained('salary_sheets')->onDelete('cascade');
            $table->string('employee_id'); // Text ID like "EMP001"
            $table->string('name');
            $table->decimal('base_salary', 15, 2);
            $table->decimal('advance', 15, 2);
            $table->decimal('net_payable', 15, 2);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('salary_archive_tables');
    }
};
