<?php

use App\Http\Controllers\InventoryController;
use App\Models\Equipment;
use App\Models\InventoryLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;


Route::get('/inventory-logs/{serial_number}', function ($sn) {
    return \App\Models\InventoryLog::where('serial_number', $sn)
        ->orderBy('created_at', 'desc')
        ->get();
});

// This creates the endpoint: http://127.0.0.1:8000/api/inventory-logs
// This fixes the 404 by creating the endpoint
Route::post('/inventory-logs', function (Request $request) {
    return InventoryLog::create([
        'serial_number'   => $request->serial_number,
        'equipment_id'    => $request->equipment_id,
        'user_id'         => Auth::id() ?? 1, // Fallback to 1 for testing
        'action'          => $request->action,
        'location_from'   => $request->location_from ?? 'Workshop',
        'location_to'     => $request->location_to ?? 'Soilmec SR-40',
        'quantity_change' => $request->quantity_change ?? 0,
        'notes'           => $request->notes,
    ]);
});

// Ensure this matches the URL in your Vue file exactly
Route::post('/inventory/ai-search/{serialNumber}', [InventoryController::class, 'askAiAboutHistory']);
