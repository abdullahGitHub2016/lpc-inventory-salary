<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('advance_reasons', function (Blueprint $table) {
            $table->id();
            $table->string('reason_name'); // e.g., Medical, Family, Education
            $table->timestamps();
        });

        // Now, update salary_advances to use the ID instead of text
        Schema::table('salary_advances', function (Blueprint $table) {
            $table->foreignId('reason_id')->nullable()->after('employee_id')->constrained('advance_reasons');
        });
    }

    public function down(): void
    {
        Schema::table('salary_advances', function (Blueprint $table) {
            $table->dropForeign(['reason_id']);
            $table->dropColumn('reason_id');
        });
        Schema::dropIfExists('advance_reasons');
    }
};
