<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Use Schema::table instead of Schema::create
        Schema::table('salary_advances', function (Blueprint $table) {
            // Add the columns only if they don't exist
            if (!Schema::hasColumn('salary_advances', 'reason_id')) {
                $table->foreignId('reason_id')->nullable()->after('employee_id')->constrained('advance_reasons');
            }
            if (!Schema::hasColumn('salary_advances', 'status')) {
                $table->string('status')->default('pending')->after('amount');
            }
        });
    }

    public function down(): void
    {
        Schema::table('salary_advances', function (Blueprint $table) {
            $table->dropForeign(['reason_id']);
            $table->dropColumn(['reason_id', 'status']);
        });
    }
};
