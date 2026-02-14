<?php

namespace App\Http\Controllers;

use App\Models\Brand;
use App\Models\Category;
use App\Models\Employee;
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

            'employees' => Employee::where('designation', 'LIKE', '%Mechanic%')
                ->orWhere('designation', 'LIKE', '%Technician%')
                ->orWhere('designation', 'LIKE', '%Engineer%')
                ->get(['id', 'name', 'designation']), // Keep designation so we can show it in Vue
            // Paginated Rigs with relationships for History & Spares
            'equipment' => Equipment::with(['currentSite', 'maintenanceLogs', 'spares'])
                ->where('is_attachment', 0)
                ->paginate(15)
                ->withQueryString(),


            // Warehouse Items
            'depoSpares' => Equipment::with(['currentSite', 'maintenanceLogs'])
                ->where('is_attachment', 1)
                ->with(['currentSite', 'parent']) // <--- Load the Rig it belongs to
                ->get(),

            // Non-paginated list for the "Link to Rig" dropdown
            'allRigs' => Equipment::where('is_attachment', 0)->get(),

            'categories' => Category::all(),
            'brands' => Brand::all(),
            'sites' => Site::all(),
        ]);
    }
    // app/Http/Controllers/InventoryController.php

    // InventoryController.php

    // Function for the Fleet Page
    // InventoryController.php
    public function fleetIndex(Request $request)
    {
        $search = $request->input('search');

        $equipment = Equipment::where('is_attachment', 0)
            ->when($search, function ($query, $search) {
                $query->where('name', 'like', "%{$search}%")
                    ->orWhere('serial_number', 'like', "%{$search}%");
            })
            // CRITICAL: Eager load maintenance_logs and the mechanic relationship
            ->with(['currentSite', 'spares', 'maintenanceLogs.mechanic'])
            ->latest()
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('Inventory/FleetList', [
            'equipment' => $equipment,
            'sites' => Site::all(),
            'employees' => Employee::all(),
        ]);
    }
    // Function for the Depo Page
    // 1. The main Depo Page function
    public function depoIndex(Request $request)
    {
        $search = $request->input('search');

        return Inertia::render('Inventory/DepoList', [
            'depoSpares' => Equipment::where('is_attachment', 1)
                ->when($search, function ($query, $search) {
                    $query->where('name', 'like', "%{$search}%")
                        ->orWhere('serial_number', 'like', "%{$search}%");
                })
                // CRITICAL: Eager load 'parent' to see the linked Rig name
                ->with(['currentSite', 'parent'])
                ->latest()
                ->paginate(15)
                ->withQueryString(),

            'allRigs' => Equipment::where('is_attachment', 0)->get(),
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

    // InventoryController.php

    public function handleTransfer(Request $request, $id)
    {
        $request->validate(['to_site_id' => 'required|exists:sites,id']);

        $equipment = Equipment::findOrFail($id);

        // Ensure this matches your column name: 'current_site_id'
        $equipment->update([
            'current_site_id' => $request->to_site_id
        ]);

        return back(); // This triggers the 303 refresh
    }
    public function linkSpare(Request $request)
    {
        $request->validate([
            'spare_id' => 'required|exists:equipment,id',
            'parent_id' => 'required|exists:equipment,id',
        ]);

        $parent = Equipment::findOrFail($request->parent_id);
        $spare = Equipment::findOrFail($request->spare_id);

        $spare->update([
            'parent_id' => $request->parent_id,
            // Sync site with parent rig so it doesn't stay in "Warehouse"
            'current_site_id' => $parent->current_site_id,
            'status' => 'Working'
        ]);

        return back()->with('success', 'Spare linked successfully');
    }
    // app/Http/Controllers/InventoryController.php

    // app/Http/Controllers/InventoryController.php
    public function unlinkSpare($id)
    {
        // 1. Find the spare item by ID
        $spare = Equipment::findOrFail($id);

        // 2. Clear the parent_id and reset status
        $spare->update([
            'parent_id' => null,
            'status' => 'In Stock'
        ]);

        // 3. Return back to refresh the Inertia props
        return back()->with('success', 'Component unlinked and moved to warehouse.');
    }    // app/Http/Controllers/InventoryController.php
    // InventoryController.php
    public function getLogs($id)
    {
        $logs = \App\Models\MaintenanceRecord::where('equipment_id', $id)
            ->with('mechanic:id,name') // Assumes a 'mechanic' relationship exists in your Model
            ->orderBy('service_date', 'desc')
            ->orderBy('id', 'desc') // Secondary sort by ID in descending order
            ->get();

        return response()->json($logs);
    }

    public function storeServiceLog(Request $request)
    {
        $validated = $request->validate([
            'equipment_id'  => 'required|exists:equipment,id',
            'mechanic_id'   => 'required|exists:employees,id',
            'service_date'  => 'required|date',
            'running_hours' => 'required|numeric',
            'service_type'  => 'required|string|max:255',
            'parts_replaced' => 'nullable|string',
        ]);

        \App\Models\MaintenanceRecord::create($validated);

        // This triggers the 302 redirect that Inertia needs to refresh the props
        return back()->with('success', 'Log added successfully');
    }
}
