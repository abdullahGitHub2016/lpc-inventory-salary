<?php

use App\Http\Controllers\InventoryController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\SalaryController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;




Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});


Route::middleware('auth')->group(function () {

    Route::post('/inventory', [InventoryController::class, 'store'])->name('inventory.store');
    Route::put('/inventory/{id}', [InventoryController::class, 'update'])->name('inventory.update');
    Route::put('/inventory/{id}', [InventoryController::class, 'update'])->name('inventory.update');
    Route::delete('/inventory/{id}', [InventoryController::class, 'destroy'])->name('inventory.destroy');
    // Inventory Routes
    Route::get('/inventory', [InventoryController::class, 'index'])->name('inventory.index');
    Route::get('/inventory/transfer', [InventoryController::class, 'transfer'])->name('inventory.transfer');

    // Post route for when the form is submitted
    Route::post('/inventory/transfer', [InventoryController::class, 'storeTransfer'])->name('inventory.transfer.store');
    Route::get('/inventory/{id}/history', [InventoryController::class, 'history'])->name('inventory.history');

    Route::post('/inventory/link-spare', [InventoryController::class, 'linkSpare'])->name('inventory.linkSpare');
    Route::post('/inventory/unlink-spare', [InventoryController::class, 'unlinkSpare'])->name('inventory.unlinkSpare');
});


Route::middleware(['auth'])->group(function () {

    // 1. Main Salary Dashboard (The View you created)
    Route::get('/salary', [SalaryController::class, 'index'])->name('salary.index');

    // 2. Advanced Management (Store the deduction)
    Route::post('/salary/advance', [SalaryController::class, 'storeAdvance'])->name('salary.advance.store');

    // 3. Leave Management (The 3-day vs 5-day logic)
    // This route will be called when an employee returns to mark their attendance
    Route::post('/salary/leave/return', [SalaryController::class, 'processReturn'])->name('salary.leave.return');

    // 4. (Optional) Process Final Monthly Payout
    Route::post('/salary/process-monthly', [SalaryController::class, 'processMonthly'])->name('salary.process');
});

require __DIR__ . '/auth.php';
