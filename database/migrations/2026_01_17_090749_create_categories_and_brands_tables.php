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
    // Create Categories Table
    Schema::create('categories', function (Blueprint $table) {
        $table->id();
        $table->string('name'); // e.g., Machinery, Testing, Tools
        $table->timestamps();
    });

    // Create Brands Table
    Schema::create('brands', function (Blueprint $table) {
        $table->id();
        $table->string('name'); // e.g., SANY, Bauer, Mitutoyo
        $table->timestamps();
    });

    // Update Equipment Table
    Schema::table('equipment', function (Blueprint $table) {
        // Drop old string columns if you added them before
        if (Schema::hasColumn('equipment', 'category')) {
            $table->dropColumn(['category', 'brand']);
        }

        // Add foreign key IDs
        $table->foreignId('category_id')->nullable()->constrained('categories')->onDelete('set null');
        $table->foreignId('brand_id')->nullable()->constrained('brands')->onDelete('set null');
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('categories_and_brands_tables');
    }
};
