<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('leaves', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_id')->constrained()->onDelete('cascade');
            $table->date('start_date');
            $table->date('end_date');
            // The 4th day in your example (when they are supposed to be back)
            $table->date('expected_return_date');
            // The actual date they showed up
            $table->date('actual_return_date')->nullable();
            // Status: Approved, Cancelled (if late), or Completed
            $table->string('status')->default('Approved');
            $table->text('remarks')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('leaves');
    }
};
