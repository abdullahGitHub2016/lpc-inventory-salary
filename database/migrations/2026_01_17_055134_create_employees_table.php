<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('employees', function (Blueprint $table) {
            $table->id();
            $table->string('employee_id')->unique(); // e.g., PIL-101
            $table->string('name');
            $table->string('designation'); // Welder, GM, etc.
            $table->decimal('total_salary', 12, 2);
            $table->foreignId('user_id')->nullable()->constrained('users'); // For login
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('employees');
    }
};
