<?php

// app/Models/Leave.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Leave extends Model
{
    protected $fillable = [
        'employee_id',
        'start_date',
        'end_date',
        'expected_return_date',
        'status', // 'Approved', 'Cancelled', 'Completed'
        'leave_type' // 'Paid', 'Unpaid'
    ];

    public function employee() {
        return $this->belongsTo(Employee::class);
    }
}
