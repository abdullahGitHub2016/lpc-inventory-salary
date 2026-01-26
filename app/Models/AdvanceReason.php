<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdvanceReason extends Model
{
    use HasFactory;

    // Matches your table name
    protected $table = 'advance_reasons';

    protected $fillable = ['reason_name'];

    // Relationship to SalaryAdvance
    public function advances()
    {
        return $this->hasMany(SalaryAdvance::class, 'reason_id');
    }
}
