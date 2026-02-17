<?php

use App\Http\Controllers\HomeController;
use App\Http\Controllers\SalaryController;
use App\Http\Controllers\SalaryArchiveController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\InventoryController;




// --- 2. SYSTEM HUB (HOME) ---
Route::middleware(['auth'])->group(function () {
    // Dashboard Home
    Route::get('/dashboard', [HomeController::class, 'index'])->name('dashboard');
    Route::get('/', [HomeController::class, 'index'])->name('dashboard');

    // ADVANCE REASONS - Fixed Route Names
    Route::post('/settings/reasons', [HomeController::class, 'storeReason'])->name('settings.reasons.store');
    Route::delete('/settings/reasons/{id}', [HomeController::class, 'destroyReason'])->name('settings.reasons.destroy');
    // Note: Usually "Edit" is handled by the store/update logic in a modal
    // web.php
    Route::patch('/settings/reasons/{id}', [HomeController::class, 'updateReason'])->name('settings.reasons.update');
});

// --- 3. PROFILE MANAGEMENT (Required by Layout) ---
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

// --- 4. SALARY & PAYROLL MODULE ---
Route::middleware(['auth'])->group(function () {
    Route::get('/salary', [SalaryController::class, 'index'])->name('salary.index');
    Route::post('/salary/advance', [SalaryController::class, 'storeAdvance'])->name('salary.advance.store');
    Route::post('/salary/process-monthly', [SalaryController::class, 'processMonthly'])->name('salary.process');

    // Archive Sub-Module
    Route::prefix('salary/archive')->group(function () {
        Route::get('/', [SalaryArchiveController::class, 'index'])->name('salary.archive.index');
        Route::get('/{year}/{month}', [SalaryArchiveController::class, 'show'])->name('salary.archive.show');
        Route::delete('/{month}/{year}', [SalaryController::class, 'destroyArchive'])->name('salary.archive.destroy');
        Route::post('/rollback/{month}/{year}', [SalaryController::class, 'rollbackArchive'])->name('salary.archive.rollback');
    });
});

// --- 5. INVENTORY MODULE (Using your InventoryController) ---
Route::middleware(['auth'])->group(function () {
    // This naming must match the 'route()' call in your Dashboard.vue
    // routes/web.php

    // Route for Main Rigs
    Route::get('/fleet', [InventoryController::class, 'fleetIndex'])->name('inventory.fleet');

    // Route for Warehouse/Spares
    Route::get('/depo', [InventoryController::class, 'depoIndex'])->name('inventory.depo');

    Route::get('/inventory', [InventoryController::class, 'fleetIndex'])->name('inventory.fleet');

    // Add your other existing inventory routes here
    Route::post('/inventory', [InventoryController::class, 'store'])->name('inventory.store');
    Route::put('/inventory/{id}', [InventoryController::class, 'update'])->name('inventory.update');
    Route::delete('/inventory/{id}', [InventoryController::class, 'destroy'])->name('inventory.destroy');

    // 1. Add the POST route for storing new logs
    Route::get('/inventory/equipment/{id}/logs', [InventoryController::class, 'getLogs'])->name('inventory.logs.fetch');

    Route::post('/inventory/link-spare', [InventoryController::class, 'linkSpare'])
        ->name('inventory.link-spare');

    Route::put('/inventory/link-spare', [InventoryController::class, 'linkSpare'])
        ->name('inventory.link-spare');
    // Ensure this is inside your auth or web middleware group
    Route::post('/inventory/unlink-spare/{id}', [InventoryController::class, 'unlinkSpare'])
        ->name('inventory.unlink-spare');
    // Change Route::put to Route::post
    Route::put('/inventory/transfer/{id}', [InventoryController::class, 'handleTransfer'])
        ->name('inventory.transfer');

    Route::post('/inventory/service-logs', [InventoryController::class, 'storeServiceLog'])
        ->name('inventory.service-logs.store');

    // 2. These are the routes that were causing the conflict
    Route::put('/inventory/service-logs/{id}', [InventoryController::class, 'updateServiceLog'])
        ->name('inventory.service-logs.update');

    Route::delete('/inventory/service-logs/{id}', [InventoryController::class, 'destroyServiceLog'])
        ->name('inventory.service-logs.destroy');

    Route::get('/inventory/rig/{id}/spares', [InventoryController::class, 'rigSpares'])->name('inventory.rig.spares');
    Route::post('/inventory/rig/{id}/add-spare', [InventoryController::class, 'addSpareToCatalogue'])
        ->name('inventory.rig.add-spare');
    Route::get('/inventory/rig/{id}', [InventoryController::class, 'rigSpares'])->name('inventory.rig.show');
    Route::get('/inventory/lookup-part/{serial}', [InventoryController::class, 'lookupPart']);
    // Make sure this exists and matches your Vue axios/router call
    Route::post('/inventory/rig/{id}/upload-manuals', [InventoryController::class, 'uploadDocuments'])
        ->name('inventory.rig.upload-manuals');
    Route::delete('/inventory/documents/{id}', [InventoryController::class, 'deleteDocument'])
        ->name('inventory.documents.delete');
    Route::post('/inventory/stock-update', [InventoryController::class, 'quickUpdateStock'])->name('inventory.stock-update');
    Route::get('/api/inventory-logs/{serial_number}', function ($sn) {
        return \App\Models\InventoryLog::with('user')
            ->where('serial_number', $sn)
            ->latest()
            ->get();
    });

});

// --- 1. AUTHENTICATION (Login, Logout, etc) ---
require __DIR__ . '/auth.php';
