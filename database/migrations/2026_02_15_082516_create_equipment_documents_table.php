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
        Schema::create('equipment_documents', function (Blueprint $table) {
            $table->id();
            // Link to the Rig (Equipment ID 152, etc)
            $table->foreignId('equipment_id')->constrained('equipment')->onDelete('cascade');

            $table->string('file_name');      // Original name: "Soilmec_SR40_Manual.pdf"
            $table->string('file_path');      // Path: "manuals/unique_hash.pdf"
            $table->string('file_type');      // Extension: pdf, doc, docx
            $table->bigInteger('file_size');  // In bytes

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('equipment_documents');
    }
};
