<?php

namespace App\Http\Controllers;

use App\Models\Equipment;
use App\Models\Site;
use App\Models\InventoryMovement;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;

class InventoryController extends Controller
{
// List all
    public function index() {
        return Inertia::render('Inventory/EquipmentList', [
            'equipment' => Equipment::with('currentSite')->get(),
            'sites' => Site::all()
        ]);
    }

    // INSERT: Create New Equipment
    public function store(Request $request) {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'serial_number' => 'required|unique:equipment,serial_number',
            'current_site_id' => 'required|exists:sites,id',
            'status' => 'required'
        ]);

        Equipment::create($validated);
        return redirect()->back()->with('message', 'Equipment Added!');
    }



    // DELETE: Remove Equipment
    public function destroy($id) {
        $equipment = Equipment::findOrFail($id);
        $equipment->delete();
        return redirect()->back()->with('message', 'Equipment Deleted!');
    }



    // Show the transfer form with real Sites and Equipment
    public function transfer()
{
    return Inertia::render('Inventory/TransferForm', [
        // Crucial: we need 'with' here so Vue knows the current location name
        'equipmentList' => Equipment::with('currentSite')->get(),
        'sites' => Site::all()
    ]);
}

    // Save the movement to the database
public function storeTransfer(Request $request)
{
    $request->validate([
        'equipment_id' => 'required',
        'to_site_id'   => 'required',
        'transfer_date' => 'required|date',
    ]);

    DB::transaction(function () use ($request) {
        $equipment = Equipment::findOrFail($request->equipment_id);

        // 1. Log the movement
        InventoryMovement::create([
            'equipment_id'  => $equipment->id,
            'from_site_id'  => $equipment->current_site_id, // Old site
            'to_site_id'    => $request->to_site_id,      // New site
            'transfer_date' => $request->transfer_date,
        ]);

        // 2. Update the Equipment itself
        $equipment->update([
            'current_site_id' => $request->to_site_id
        ]);
    });

    return redirect()->route('inventory.index');
}
    public function history($id)
{
    $item = Equipment::with(['movements.fromSite', 'movements.toSite'])->findOrFail($id);

    return Inertia::render('Inventory/History', [
        'equipment' => $item
    ]);
}
// UPDATE: Edit Equipment Details
   public function update(Request $request, $id)
{
    // 1. Find the equipment
    $equipment = \App\Models\Equipment::findOrFail($id);

    // 2. Validate the incoming data
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'serial_number' => 'required|unique:equipment,serial_number,' . $id,
        'status' => 'required'
    ]);

    // 3. Update the database (Removed ActivityLog to avoid errors)
    $equipment->update($validated);

    // 4. Redirect back to the list
    return redirect()->back()->with('message', 'Equipment updated successfully');
}
}
