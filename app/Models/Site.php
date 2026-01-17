<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Site extends Model
{
    protected $fillable = ['location_name', 'supervisor_id'];
}
