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
    Schema::create('maintenance_records', function (Blueprint $table) {
        $table->id();
        $table->foreignId('equipment_id')->constrained()->onDelete('cascade');

        // Links to your existing 'employees' table
        $table->foreignId('mechanic_id')->constrained('employees');

        $table->string('service_type'); // Routine, Breakdown, etc.
        $table->date('service_date');
        $table->integer('running_hours')->nullable();

        // This is where you list "Inside Body" spares like filters or seals
        $table->text('parts_replaced');

        $table->decimal('total_cost', 12, 2)->default(0);
        $table->text('remarks')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('maintenance_records');
    }
};
