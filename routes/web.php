<?php

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
});

Route::get('/seed-history', function () {
    // 1. Create December 2025 Archive
    $id = DB::table('salary_sheets')->insertGetId([
        'month' => 'December',
        'month_number' => 12,
        'year' => 2025,
        'total_payout' => 45000,
        'created_at' => now(),
    ]);

    DB::table('salary_sheet_details')->insert([
        [
            'salary_sheet_id' => $id,
            'employee_id' => 'LPC-001',
            'name' => 'John Doe',
            'base_salary' => 30000,
            'advance' => 5000,
            'net_payable' => 25000,
        ],
        [
            'salary_sheet_id' => $id,
            'employee_id' => 'LPC-002',
            'name' => 'Jane Smith',
            'base_salary' => 25000,
            'advance' => 5000,
            'net_payable' => 20000,
        ]
    ]);

    // 2. Create November 2025 Archive
    $id2 = DB::table('salary_sheets')->insertGetId([
        'month' => 'November',
        'month_number' => 11,
        'year' => 2025,
        'total_payout' => 22000,
        'created_at' => now(),
    ]);

    DB::table('salary_sheet_details')->insert([
        [
            'salary_sheet_id' => $id2,
            'employee_id' => 'LPC-001',
            'name' => 'John Doe',
            'base_salary' => 30000,
            'advance' => 8000,
            'net_payable' => 22000,
        ]
    ]);

    return "History Seeded! Go check your Archive page.";
});
require __DIR__ . '/auth.php';
