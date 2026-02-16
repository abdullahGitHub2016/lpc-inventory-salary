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
            // 1. Drop the columns we are replacing or don't need
            // We drop these to avoid the "no default value" errors
            $table->dropColumn(['new_total_stock']);

            // 2. Ensure our preferred columns have safe defaults
            $table->string('location_from')->nullable()->change();
            $table->string('location_to')->nullable()->change();

            // 3. Fix quantity_change to have a default of 0
            $table->integer('quantity_change')->default(0)->change();

            // 4. Ensure notes is nullable
            $table->text('notes')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};
