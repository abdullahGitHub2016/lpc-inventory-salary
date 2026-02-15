<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EquipmentDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'equipment_id',
        'file_name',
        'file_path',
        'file_type',
        'file_size'
    ];

    /**
     * Get the equipment (Rig) that owns this document.
     */
    public function equipment()
    {
        return $this->belongsTo(Equipment::class);
    }
}
