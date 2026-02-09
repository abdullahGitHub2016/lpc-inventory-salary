<?php

use App\Http\Controllers\EmployeeController;
use App\Http\Controllers\InventoryController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\SalaryArchiveController;
use App\Http\Controllers\SalaryController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\DB;
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

    // --- 1. LIVE COMMAND CENTER ---
    Route::get('/salary', [SalaryController::class, 'index'])->name('salary.index');
    Route::post('/salary/advance', [SalaryController::class, 'storeAdvance'])->name('salary.advance.store');

    // --- 2. LEAVE & PAYROLL LOGIC ---
    Route::post('/salary/leave/return', [SalaryController::class, 'processReturn'])->name('salary.leave.return');

    // --- 3. ARCHIVE SYSTEM ---
    Route::prefix('salary/archive')->group(function () {
        // Main Archive Grid (The "Filing Cabinet")
        Route::get('/', [SalaryArchiveController::class, 'index'])->name('salary.archive.index');

        // Detailed Monthly Statement (The "Frozen Sheet")
        Route::get('/{year}/{month}', [SalaryArchiveController::class, 'show'])->name('salary.archive.show');
    });

    // --- 4. MONTH-END CLOSING ---
    // This is the route that "Freezes" the current month and moves it to Archive
    Route::post('/salary/process-monthly', [SalaryController::class, 'processMonthly'])->name('salary.process');
    Route::delete('/salary/archive/{month}/{year}', [SalaryController::class, 'destroyArchive'])
    ->name('salary.archive.destroy');

    Route::post('/salary/archive/rollback/{month}/{year}', [SalaryController::class, 'rollbackArchive'])
    ->name('salary.archive.rollback');
});


Route::middleware(['auth'])->group(function () {
    Route::resource('employees', EmployeeController::class);
});

require __DIR__ . '/auth.php';
