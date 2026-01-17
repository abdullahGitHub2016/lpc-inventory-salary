<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InventoryMovement extends Model
{
    protected $fillable = ['equipment_id', 'from_site_id', 'to_site_id', 'transfer_date', 'remarks'];

    // The site the equipment moved FROM
    public function fromSite(): BelongsTo
    {
        return $this->belongsTo(Site::class, 'from_site_id');
    }

    // The site the equipment moved TO
    public function toSite(): BelongsTo
    {
        return $this->belongsTo(Site::class, 'to_site_id');
    }

    // Link back to the equipment itself
    public function equipment(): BelongsTo
    {
        return $this->belongsTo(Equipment::class);
    }
}
