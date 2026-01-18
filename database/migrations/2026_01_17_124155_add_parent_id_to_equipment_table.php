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
    Schema::table('equipment', function (Blueprint $table) {
        // This allows a piece of equipment to "belong" to another machine
        $table->foreignId('parent_id')
              ->nullable()
              ->after('current_site_id')
              ->constrained('equipment')
              ->onDelete('cascade');

        $table->boolean('is_attachment')->default(false);
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('equipment', function (Blueprint $table) {
            //
        });
    }
};
