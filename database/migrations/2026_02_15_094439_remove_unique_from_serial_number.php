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
    Schema::table('equipment', function (Blueprint $table) {
        // 1. Drop the unique constraint
        // Note: The index name is usually 'equipment_serial_number_unique'
        // as seen in your error message.
        $table->dropUnique(['serial_number']);

        // 2. Add a normal index so searching by Part Number is still fast
        $table->index('serial_number');
    });
}

public function down()
{
    Schema::table('equipment', function (Blueprint $table) {
        $table->unique('serial_number');
    });
}
};
