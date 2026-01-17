<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Equipment extends Model
{
    protected $fillable = ['name', 'serial_number', 'status', 'current_site_id'];

    public function currentSite(): BelongsTo
    {
        return $this->belongsTo(Site::class, 'current_site_id');
    }
    public function movements()
{
    return $this->hasMany(InventoryMovement::class)->orderBy('transfer_date', 'desc');
}
}
