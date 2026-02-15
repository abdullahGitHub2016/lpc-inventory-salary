<?php

namespace App\Http\Controllers;

use App\Models\Brand;
use App\Models\Category;
use App\Models\Employee;
use App\Models\Equipment;
use App\Models\EquipmentDocument;
use App\Models\InventoryMovement;
use App\Models\MaintenanceRecord;
use App\Models\Site;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
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
            'functional_group' => 'nullable|string', // Capture the group
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
        $request->validate([
            'to_site_id' => 'required|exists:sites,id',
        ]);

        $equipment = Equipment::findOrFail($id);

        // Update the Rig
        $equipment->update([
            'current_site_id' => $request->to_site_id
        ]);

        // Update all attached components so they "move" with the machine
        Equipment::where('parent_id', $id)->update([
            'current_site_id' => $request->to_site_id
        ]);

        return back();
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
            // SYNC SITE: The spare moves to where the Rig is
            'current_site_id' => $parent->current_site_id,
            'status' => 'Working'
        ]);

        return back();
    }

    public function unlinkSpare($id)
    {
        // 1. Find the spare item by ID
        $spare = Equipment::findOrFail($id);

        // 2. Find your "Warehouse" or "Depo" site ID
        // You can hardcode this ID or look it up by name
        $warehouse = \App\Models\Site::where('location_name', 'LIKE', '%Warehouse%')
            ->orWhere('location_name', 'LIKE', '%Depo%')
            ->first();

        // 3. Update both the link AND the location
        $spare->update([
            'parent_id' => null,
            'status' => 'In Stock',
            'current_site_id' => $warehouse ? $warehouse->id : null, // Move back to Warehouse
        ]);

        // 4. Return back to refresh the Inertia props (triggers the 303 See Other)
        return back()->with('success', 'Component unlinked and moved back to Warehouse.');
    }
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

    public function rigSpares($id)
    {
        // Load Rig with current site and uploaded documents
        $rig = Equipment::with(['currentSite', 'documents'])->findOrFail($id);

        // Get spares for this rig and calculate "Global Stock"
        $spares = Equipment::where('parent_id', $id)->get();

        // Logic to show "Stock and Site":
        // We map through spares to find how many more exist in other locations
        $sparesWithStock = $spares->map(function ($spare) {
            $spare->global_stock_count = Equipment::where('serial_number', $spare->serial_number)
                ->whereNull('parent_id') // Only count those in Warehouse/Stock
                ->count();
            return $spare;
        });

        $sparesGrouped = $sparesWithStock->groupBy('functional_group');

        $warehouseSpares = Equipment::where('is_attachment', 1)
            ->whereNull('parent_id')
            ->get();

        return Inertia::render('Inventory/RigSparesCatalogue', [
            'rig' => $rig,
            'sparesGrouped' => $sparesGrouped,
            'warehouseSpares' => $warehouseSpares,
            'existingGroups' => Equipment::distinct()->pluck('functional_group')
        ]);
    }
    public function addSpareToCatalogue(Request $request, $id)
    {
        // 1. Validate the input
        $request->validate([
            'spare_id'         => 'nullable|exists:equipment,id',
            'new_part_name'    => 'nullable|required_without:spare_id|string',
            'part_number'      => 'required|string', // This is the Serial Number in your DB
            'functional_group' => 'required|string',
        ]);

        $rig = Equipment::findOrFail($id);

        // 2. Scenario A: Linking an existing spare from the Warehouse
        if ($request->spare_id) {
            $equipment = Equipment::findOrFail($request->spare_id);

            $equipment->update([
                'parent_id'        => $rig->id,
                'functional_group' => $request->functional_group,
                'serial_number'    => $request->part_number, // Sync with PDF part number
                'current_site_id'  => $rig->current_site_id, // Inherit Rig's location
                'status'           => 'Working'
            ]);
        }
        // 3. Scenario B: Creating a brand new part from the PDF
        else {
            Equipment::create([
                'name'             => $request->new_part_name,
                'serial_number'    => $request->part_number,
                'functional_group' => $request->functional_group,
                'parent_id'        => $rig->id,
                'current_site_id'  => $rig->current_site_id, // Automatically place it where the Rig is
                'status'           => 'Working',
                'is_attachment'    => 1, // Mark as a spare/component
            ]);
        }

        return back()->with('success', 'Catalogue updated successfully.');
    }
    public function lookupPart($serial)
    {
        // Find the part and include its current parent (machine) name if it has one
        $part = Equipment::with('parent')->where('serial_number', $serial)->first();

        return response()->json([
            'exists' => !!$part,
            'part'   => $part,
            'is_attached' => $part && $part->parent_id !== null
        ]);
    }
    public function uploadDocuments(Request $request, $id)
    {
        // 1. Debug: Check if the request even hits this method
        // dd($request->all());

        $rig = Equipment::findOrFail($id); // If $id is wrong, this returns 404

        if ($request->hasFile('documents')) {
            foreach ($request->file('documents') as $file) {
                // Store in 'public/manuals' folder
                $path = $file->store('manuals', 'public');

                $rig->documents()->create([
                    'file_name' => $file->getClientOriginalName(),
                    'file_path' => '/storage/' . $path, // This prefix requires the storage link
                    'file_type' => $file->getClientOriginalExtension(),
                    'file_size' => $file->getSize(),
                ]);
            }
        }

        return back();
    }


    public function deleteDocument($id)
    {
        $document = EquipmentDocument::findOrFail($id);

        // 1. Remove the physical file from storage
        // We strip the "/storage/" prefix to get the relative path for the Storage facade
        $relativePath = str_replace('/storage/', '', $document->file_path);

        if (Storage::disk('public')->exists($relativePath)) {
            Storage::disk('public')->delete($relativePath);
        }

        // 2. Delete the record from the database
        $document->delete();

        return back()->with('success', 'Document deleted successfully.');
    }
}
