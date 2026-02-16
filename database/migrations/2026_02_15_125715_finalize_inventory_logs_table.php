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
            // Remove the short versions
            $table->dropColumn(['from_loc', 'to_loc', 'qty_change', 'remarks']);

            // Ensure the descriptive versions are correct (adding/modifying as needed)
            // We use change() or adding if they don't exist perfectly
            if (!Schema::hasColumn('inventory_logs', 'location_from')) {
                $table->string('location_from')->nullable()->after('action');
            }
            if (!Schema::hasColumn('inventory_logs', 'location_to')) {
                $table->string('location_to')->nullable()->after('location_from');
            }
            if (!Schema::hasColumn('inventory_logs', 'quantity_change')) {
                $table->integer('quantity_change')->default(0)->after('location_to');
            }
            if (!Schema::hasColumn('inventory_logs', 'notes')) {
                $table->text('notes')->nullable()->after('quantity_change');
            }
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
