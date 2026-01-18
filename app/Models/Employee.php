<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{
    // These are the fields we allow to be filled
    protected $fillable = [
        'employee_id',
        'name',
        'designation',
        'total_salary'
    ];

// To see which repairs a mechanic has performed
public function maintenancePerformed() {
    return $this->hasMany(MaintenanceRecord::class, 'mechanic_id');
}

}
