<?php

namespace App\Http\Controllers;

use App\Models\Site;
use App\Models\Equipment;
use Illuminate\Http\Request;
use Inertia\Inertia;

class SiteController extends Controller
{
    /**
     * Display a listing of the sites.
     */
    public function index()
    {
        return Inertia::render('Sites/Index', [
            'sites' => Site::orderBy('location_name')->get()
        ]);
    }

    /**
     * Store a newly created site in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'location_name' => 'required|string|max:255|unique:sites,location_name',
        ]);

        Site::create($validated);

        return redirect()->back()->with('message', 'Site created successfully.');
    }

    /**
     * Update the specified site in storage.
     */
    public function update(Request $request, $id)
    {
        $site = Site::findOrFail($id);

        $validated = $request->validate([
            'location_name' => 'required|string|max:255|unique:sites,location_name,' . $id,
        ]);

        $site->update($validated);

        return redirect()->back()->with('message', 'Site updated successfully.');
    }

    /**
     * Remove the specified site from storage.
     */
    public function destroy($id)
    {
        $site = Site::findOrFail($id);

        // Safety Check: Prevent deletion if equipment is still assigned to this site
        $equipmentCount = Equipment::where('current_site_id', $id)->count();

        if ($equipmentCount > 0) {
            return redirect()->back()->withErrors([
                'delete' => 'Cannot delete site. There are ' . $equipmentCount . ' units currently assigned to this location.'
            ]);
        }

        $site->delete();

        return redirect()->back()->with('message', 'Site deleted successfully.');
    }
}
