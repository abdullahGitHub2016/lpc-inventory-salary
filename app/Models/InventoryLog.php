<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InventoryLog extends Model
{
    //
    protected $fillable = [
        'serial_number',
        'equipment_id',
        'user_id',
        'action',
        'location_from',
        'location_to',
        'quantity_change',
        'notes'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
