<?php

namespace App\Http\Controllers;

use App\Models\AdvanceReason;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function index()
    {
        return \Inertia\Inertia::render('Dashboard', [
            'advanceReasons' => AdvanceReason::all()
        ]);
    }

    public function storeReason(Request $request)
    {
        // Validate matching your DB column 'reason_name'
        $request->validate([
            'reason_name' => 'required|string|max:255|unique:advance_reasons,reason_name'
        ]);

        AdvanceReason::create([
            'reason_name' => $request->reason_name
        ]);

        return back();
    }

    public function destroyReason($id)
    {
        AdvanceReason::findOrFail($id)->delete();
        return back();
    }

    public function updateReason(Request $request, $id)
    {
        $request->validate([
            'reason_name' => 'required|string|max:255|unique:advance_reasons,reason_name,' . $id
        ]);

        $reason = AdvanceReason::findOrFail($id);
        $reason->update([
            'reason_name' => $request->reason_name
        ]);

        return back();
    }
}
