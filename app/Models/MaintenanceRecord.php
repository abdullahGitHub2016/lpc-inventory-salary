<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MaintenanceRecord extends Model
{
    use HasFactory;

    // Mass assignable fields for internal spares and service info
    protected $fillable = [
        'equipment_id',
        'mechanic_id',
        'service_type',
        'service_date',
        'running_hours',
        'parts_replaced', // This stores your "Inside Body" spares
        'total_cost',
        'remarks'
    ];

    // Ensure this relationship exists so Laravel can load the mechanic's name
    public function mechanic()
    {
        return $this->belongsTo(Employee::class, 'mechanic_id');
    }

    public function equipment()
    {
        return $this->belongsTo(Equipment::class);
    }
}
