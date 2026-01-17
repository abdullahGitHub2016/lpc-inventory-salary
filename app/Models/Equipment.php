<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Equipment extends Model
{
    protected $fillable = ['name', 'serial_number', 'category_id', 'brand_id', 'status', 'current_site_id'];

// Relationship to Category
public function category() {
    return $this->belongsTo(Category::class);
}

// Relationship to Brand
public function brand() {
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
}
