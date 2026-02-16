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
        Schema::table('inventory_logs', function (Blueprint $table) {
            // Only add these if they aren't already there
            $table->string('from_loc')->after('action')->nullable();
            $table->string('to_loc')->after('from_loc')->nullable();
            $table->integer('qty_change')->after('to_loc')->default(0);
            $table->text('remarks')->after('qty_change')->nullable();
        });
    }
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('inventory_logs', function (Blueprint $table) {
            //
        });
    }
};
