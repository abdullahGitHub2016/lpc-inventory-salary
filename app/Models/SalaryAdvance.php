<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SalaryAdvance extends Model
{
    // Ensure ALL these are here
    protected $fillable = [
        'employee_id', // This should link to the 'id' (BIGINT) of the employee
        'reason_id',   // The ID from advance_reasons table
        'amount',
        'advance_date',
        'status'       // 'pending' or 'paid'
    ];

    public function employee()
    {
        return $this->belongsTo(Employee::class, 'employee_id', 'id');
    }

    public function reason()
{
    // Points to the advance_reasons table
    return $this->belongsTo(AdvanceReason::class, 'reason_id');
}
}
