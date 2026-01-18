<?php

namespace App\Http\Controllers;

use App\Models\Brand;
use App\Models\Category;
use App\Models\Equipment;
use App\Models\InventoryMovement;
use App\Models\MaintenanceRecord;
use App\Models\Site;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class InventoryController extends Controller
{
    /**
     * Main Dashboard: Lists Rigs (Paginated) and Depo Spares (List)
     */
    public function index(Request $request)
    {
        return Inertia::render('Inventory/EquipmentList', [
            // Paginated Rigs with relationships for History & Spares
            'equipment' => Equipment::with(['currentSite', 'maintenanceLogs', 'spares'])
                ->where('is_attachment', 0)
                ->paginate(15)
                ->withQueryString(),

            // Warehouse Items
            'depoSpares' => Equipment::with(['currentSite', 'maintenanceLogs'])
                ->where('is_attachment', 1)
                ->whereNull('parent_id')
                ->get(),

            // Non-paginated list for the "Link to Rig" dropdown
            'allRigs' => Equipment::where('is_attachment', 0)->get(),

            'categories' => Category::all(),
            'brands' => Brand::all(),
            'sites' => Site::all(),
        ]);
    }

    /**
     * RESTORED: Create New Equipment/Spare with is_attachment support
     */
    // app/Http/Controllers/InventoryController.php

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'            => 'required|string|max:255',
            'serial_number'   => 'required|unique:equipment,serial_number',
            'current_site_id' => 'required|exists:sites,id',
            'status'          => 'required|string',
            'is_attachment'   => 'required|integer', // Validate the payload value
            'category_id'     => 'nullable|exists:categories,id',
            'brand_id'        => 'nullable|exists:brands,id',
        ]);

        // Now $validated contains 'is_attachment', so it will be saved
        Equipment::create($validated);

        return redirect()->back()->with('message', 'Item Added Successfully!');
    }

    /**
     * RESTORED: Show the standalone transfer form
     */
    public function transfer()
    {
        return Inertia::render('Inventory/TransferForm', [
            'equipmentList' => Equipment::with('currentSite')->get(),
            'sites' => Site::all()
        ]);
    }

    /**
     * RESTORED: Process the movement and update current_site_id
     */
    public function storeTransfer(Request $request)
    {
        $request->validate([
            'equipment_id' => 'required',
            'to_site_id'   => 'required',
            'transfer_date' => 'required|date',
        ]);

        DB::transaction(function () use ($request) {
            $equipment = Equipment::findOrFail($request->equipment_id);

            // 1. Log the movement in history
            InventoryMovement::create([
                'equipment_id'  => $equipment->id,
                'from_site_id'  => $equipment->current_site_id,
                'to_site_id'    => $request->to_site_id,
                'transfer_date' => $request->transfer_date,
            ]);

            // 2. Update the Equipment's current location
            $equipment->update([
                'current_site_id' => $request->to_site_id
            ]);
        });

        return redirect()->route('inventory.index')->with('message', 'Transfer logged!');
    }

    /**
     * RESTORED: Detailed History view including movements
     */
    public function history($id)
    {
        $item = Equipment::with(['movements.fromSite', 'movements.toSite'])->findOrFail($id);

        return Inertia::render('Inventory/History', [
            'equipment' => $item
        ]);
    }

    /**
     * RESTORED: Dedicated Warehouse/Spares Stock view
     */
    public function sparesIndex()
    {
        return Inertia::render('Inventory/SparesStock', [
            'spares' => Equipment::where('is_attachment', 1)
                ->whereNull('parent_id')
                ->get(),
            'sites' => Site::all()
        ]);
    }

    /**
     * Update existing item details
     */
    public function update(Request $request, $id)
    {
        $equipment = Equipment::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'serial_number' => 'required|unique:equipment,serial_number,' . $id,
            'status' => 'required'
        ]);

        $equipment->update($validated);
        return redirect()->back()->with('message', 'Updated successfully');
    }

    /**
     * Delete item
     */
    public function destroy($id)
{
    $item = Equipment::findOrFail($id);

    // If it's a Rig, unlink its spares before deleting
    if ($item->is_attachment == 0) {
        Equipment::where('parent_id', $item->id)->update([
            'parent_id' => null,
            'is_attachment' => 1,
            'status' => 'In Stock'
        ]);
    }

    $item->delete();

    return redirect()->back()->with('message', 'Item deleted successfully');
}

    // app/Http/Controllers/InventoryController.php

    public function linkSpare(Request $request)
    {
        $request->validate([
            'spare_id' => 'required|exists:equipment,id',
            'parent_id' => 'required|exists:equipment,id',
        ]);

        $spare = Equipment::findOrFail($request->spare_id);

        // Update the spare to link it to the Rig
        $spare->update([
            'parent_id' => $request->parent_id,
            'is_attachment' => 1, // Ensure it stays marked as an attachment
            'current_site_id' => Equipment::find($request->parent_id)->current_site_id // Match the Rig's location
        ]);

        return redirect()->back()->with('message', 'Spare linked to Rig successfully!');
    }
// app/Http/Controllers/InventoryController.php

public function unlinkSpare(Request $request)
{
    $request->validate([
        'spare_id' => 'required|exists:equipment,id',
    ]);

    $spare = Equipment::findOrFail($request->spare_id);

    // Reset parent and move back to general stock
    $spare->update([
        'parent_id' => null,
        'is_attachment' => 1,
        // Optionally set status to 'In Stock' when unlinked
        'status' => 'In Stock'
    ]);

    return redirect()->back()->with('message', 'Spare moved back to Warehouse.');
}
// app/Http/Controllers/InventoryController.php

public function storeLog(Request $request)
{
    $validated = $request->validate([
        'equipment_id'    => 'required|exists:equipment,id',
        'service_date'    => 'required|date',
        'running_hours'   => 'required|numeric',
        'service_type'    => 'required|string|max:255',
        'parts_replaced'  => 'nullable|string',
        'mechanic_id'     => 'nullable|exists:employees,id', // Added based on your model
    ]);

    MaintenanceRecord::create($validated);

    return redirect()->back()->with('message', 'Service Record Added!');
}
}
