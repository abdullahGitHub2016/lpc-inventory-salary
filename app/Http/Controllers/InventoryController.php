<?php

namespace App\Http\Controllers;

use App\Models\Brand;
use App\Models\Category;
use App\Models\Employee;
use App\Models\Equipment;
use App\Models\EquipmentDocument;
use App\Models\InventoryLog;
use App\Models\InventoryMovement;
use App\Models\MaintenanceRecord;
use App\Models\Site;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use OpenAI\Laravel\Facades\OpenAI;

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
        $itemOnRig = Equipment::findOrFail($id);
        $partNumber = $itemOnRig->serial_number;

        // 1. Look for an existing "Warehouse" version of this part
        $warehouseItem = Equipment::where('serial_number', $partNumber)
            ->whereNull('parent_id')
            ->first();

        if ($warehouseItem) {
            // SCENARIO: Warehouse entry exists, just add the quantity back
            $warehouseItem->increment('quantity', $itemOnRig->quantity);

            // Remove the rig-specific entry
            $itemOnRig->delete();
        } else {
            // SCENARIO: No warehouse entry exists, make this the new warehouse entry
            $itemOnRig->update([
                'parent_id' => null,
                'functional_group' => null, // Clear the group as it's no longer on a rig
                'status' => 'In Stock'
            ]);
        }

        return back()->with('success', 'Item returned to warehouse and stock updated.');
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
        $rig = Equipment::with(['currentSite', 'documents'])->findOrFail($id);

        // 1. Get all spares for this rig
        $spares = Equipment::where('parent_id', $id)->get();

        // 2. Attach the Warehouse Stock count
        $sparesWithStock = $spares->map(function ($spare) {
            $spare->warehouse_stock = Equipment::where('serial_number', $spare->serial_number)
                ->whereNull('parent_id')
                ->sum('quantity');

            return $spare;
        });

        $sparesGrouped = $sparesWithStock->groupBy('functional_group');

        return Inertia::render('Inventory/RigSparesCatalogue', [
            'rig' => $rig,
            'inventory' => $sparesWithStock, // FIX: Pass the actual spares list here
            'sparesGrouped' => $sparesGrouped,
            'warehouseSpares' => Equipment::where('is_attachment', 1)->whereNull('parent_id')->get(),
            'existingGroups' => Equipment::whereNotNull('functional_group')
                ->where('functional_group', '!=', '')
                ->distinct()
                ->orderBy('functional_group', 'asc')
                ->pluck('functional_group')
        ]);
    }

    public function addSpareToCatalogue(Request $request, $id)
    {
        $rig = Equipment::findOrFail($id);
        $qtyToAdd = (int) $request->input('quantity_to_add', 1);
        $partNumber = $request->part_number;

        // 1. UPDATE OR CREATE THE PART ON THIS SPECIFIC RIG
        // This looks for the part NUMBER on THIS RIG ID only.
        $rigPart = Equipment::where('parent_id', $rig->id)
            ->where('serial_number', $partNumber)
            ->first();

        if ($rigPart) {
            $rigPart->increment('quantity', 1); // We keep 1 active on the rig
        } else {
            $newPart = Equipment::create([
                'name' => $request->new_part_name,
                'serial_number' => $partNumber,
                'parent_id' => $rig->id,
                'quantity' => 1,
                'functional_group' => $request->functional_group,
                'current_site_id' => $rig->current_site_id,
                'is_attachment' => 1,
                'status' => 'Working'
            ]);
        }

        \App\Models\InventoryLog::create([
            'serial_number'   => $request->part_number,
            'equipment_id'    => $newPart->id, // <--- THIS SAVES THE ID OF THE RIG-SPECIFIC PART
            'user_id'         => Auth::id(),
            'action'          => 'Installation',
            'location_from'   => 'Main Warehouse',
            'location_to'     => $rig->name,
            'quantity_change' => -1,
            'notes'           => "Linked to rig group: " . $request->functional_group
        ]);

        // 2. HANDLE THE REMAINDER IN THE WAREHOUSE
        $remainder = $qtyToAdd - 1;
        if ($remainder > 0) {
            // Find stock in the warehouse (where parent_id is NULL)
            // You could also filter by 'current_site_id' if you have multiple warehouses
            $warehouseItem = Equipment::whereNull('parent_id')
                ->where('serial_number', $partNumber)
                ->first();

            if ($warehouseItem) {
                $warehouseItem->increment('quantity', $remainder);
            } else {
                Equipment::create([
                    'name' => $request->new_part_name,
                    'serial_number' => $partNumber,
                    'parent_id' => null, // Warehouse
                    'quantity' => $remainder,
                    'current_site_id' => 1, // Main Warehouse Site
                    'status' => 'In Stock',
                ]);
            }
        }

        return back();
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

    public function quickUpdateStock(Request $request)
    {
        $warehouseItem = Equipment::where('serial_number', $request->serial_number)
            ->whereNull('parent_id')
            ->first();

        if ($warehouseItem) {
            $warehouseItem->update(['quantity' => $request->quantity]);
        } else {
            // Create warehouse entry if it didn't exist
            $ref = Equipment::where('serial_number', $request->serial_number)->first();
            Equipment::create([
                'name' => $ref->name ?? 'New Spare',
                'serial_number' => $request->serial_number,
                'quantity' => $request->quantity,
                'parent_id' => null,
                'status' => 'In Stock',
                'is_attachment' => 1
            ]);
        }
        return back();
    }

    public function askAiAboutHistory(Request $request, $serialNumber)
    {
        set_time_limit(1020);
        try {
            $logs = InventoryLog::where('serial_number', $serialNumber)->get();

            if ($logs->isEmpty()) {
                return response()->json(['answer' => "No history found for this serial."]);
            }

            $historyContext = $logs->map(fn($l) => "Action: {$l->action}, Note: {$l->notes}")->implode("\n");

            $result = OpenAI::chat()->create([
                'model' => 'llama3.2', // Change this to match your Ollama model
                'messages' => [
                    ['role' => 'system', 'content' => 'You are a maintenance assistant...'],
                    ['role' => 'user', 'content' => "History:\n$historyContext\n\nQuestion: {$request->question}"]
                ],
            ]);

            return response()->json(['answer' => $result->choices[0]->message->content]);
        } catch (\Exception $e) {
            // This will send the real error message back to your Vue console!
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
