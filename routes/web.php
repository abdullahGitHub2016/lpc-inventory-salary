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
    Route::get('/inventory', [InventoryController::class, 'index'])->name('inventory.index');

    // Add your other existing inventory routes here
    Route::post('/inventory', [InventoryController::class, 'store'])->name('inventory.store');
    Route::put('/inventory/{id}', [InventoryController::class, 'update'])->name('inventory.update');
    Route::delete('/inventory/{id}', [InventoryController::class, 'destroy'])->name('inventory.destroy');
});

// --- 1. AUTHENTICATION (Login, Logout, etc) ---
require __DIR__.'/auth.php';
