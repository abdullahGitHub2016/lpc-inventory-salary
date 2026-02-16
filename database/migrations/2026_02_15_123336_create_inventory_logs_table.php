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
    Schema::create('inventory_logs', function (Blueprint $table) {
        $table->id();
        $table->string('serial_number')->index(); // Link by Part Number
        $table->unsignedBigInteger('equipment_id')->nullable(); // Link to specific row
        $table->foreignId('user_id')->constrained(); // Who did it

        $table->string('action'); // 'Added', 'Installed', 'Removed', 'Updated Stock'
        $table->string('location_from')->nullable();
        $table->string('location_to')->nullable();

        $table->integer('quantity_change'); // +5, -1, etc.
        $table->integer('new_total_stock'); // The result after change

        $table->text('notes')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('inventory_logs');
    }
};
