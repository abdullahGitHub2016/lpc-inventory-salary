<?php

namespace App\Models;

use App\Models\MaintenanceRecord;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Equipment extends Model
{
    protected $fillable = [
    'name',
    'serial_number',
    'current_site_id',
    'status',
    'is_attachment', // ADD THIS
    'category_id',   // ADD THIS
    'brand_id',      // ADD THIS
    'parent_id',
    'model',
];

    // Relationship to Category
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    // Relationship to Brand
    public function brand()
    {
        return $this->belongsTo(Brand::class);
    }

    public function currentSite(): BelongsTo
    {
        return $this->belongsTo(Site::class, 'current_site_id');
    }
    public function movements()
    {
        return $this->hasMany(InventoryMovement::class)->orderBy('transfer_date', 'desc');
    }

// Relationship for "Outside" spares
public function spares() {
    return $this->hasMany(Equipment::class, 'parent_id');
}

// Relationship for "Inside" maintenance history
public function maintenanceLogs() {
    return $this->hasMany(MaintenanceRecord::class);
}
}
