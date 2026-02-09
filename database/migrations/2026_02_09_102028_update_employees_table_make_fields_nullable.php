<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('employees', function (Blueprint $table) {
            // Change designation to nullable
            $table->string('designation')->nullable()->change();

            // Use 'total_salary' because 'base_salary' does not exist in your table
            $table->decimal('total_salary', 15, 2)->default(0.00)->change();
        });
    }

    public function down(): void
    {
        Schema::table('employees', function (Blueprint $table) {
            $table->string('designation')->nullable(false)->change();
            $table->decimal('total_salary', 15, 2)->default(null)->change();
        });
    }
};
