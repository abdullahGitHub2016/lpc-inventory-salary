<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Employee extends Model
{
    // These are the fields we allow to be filled
    protected $fillable = [
        'employee_id', // This is your unique string ID
        'name',
        'designation',
        'total_salary',
        'user_id'
    ];

    // To see which repairs a mechanic has performed
    public function maintenancePerformed()
    {
        return $this->hasMany(MaintenanceRecord::class, 'mechanic_id');
    }

    public function advances(): HasMany
    {
        return $this->hasMany(SalaryAdvance::class, 'employee_id', 'id');
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($employee) {
            // Logic: Find the latest ID and increment it, or use a UUID
            $latest = static::latest('id')->first();
            $nextId = $latest ? ($latest->id + 1) : 1;
            $employee->employee_id = 'EMP-' . str_pad($nextId, 4, '0', STR_PAD_LEFT);
        });
    }
}
