<?php

namespace App\Http\Controllers;

use App\Models\Brand;
use App\Models\Category;
use App\Models\Equipment;
use App\Models\InventoryMovement;
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
        // 1. Fetch Main Rigs (Assets) with Pagination
        $equipment = Equipment::with(['currentSite', 'maintenanceLogs.mechanic', 'spares'])
            ->whereNull('parent_id')
            ->where('is_attachment', 0)
            ->paginate(15)
            ->withQueryString();

        // 2. Fetch Unassigned Spares (Warehouse Stock)
        $depoSpares = Equipment::with(['currentSite'])
            ->whereNull('parent_id')
            ->where('is_attachment', 1)
            ->get();

        return Inertia::render('Inventory/EquipmentList', [
            'equipment' => $equipment,
            'depoSpares' => $depoSpares,
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
        $equipment = Equipment::findOrFail($id);
        $equipment->delete();
        return redirect()->back()->with('message', 'Deleted!');
    }
}
