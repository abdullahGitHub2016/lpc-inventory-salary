<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;

class AdvanceReasonController extends Controller
{
    public function index()
    {
        return Inertia::render('Settings/ReasonsIndex', [
            'reasons' => \App\Models\AdvanceReason::all()
        ]);
    }

    public function store(Request $request)
    {
        $request->validate(['name' => 'required|string|max:255']);
        \App\Models\AdvanceReason::create($request->all());
        return back()->with('success', 'Reason added.');
    }

    public function destroy($id)
    {
        \App\Models\AdvanceReason::findOrFail($id)->delete();
        return back()->with('success', 'Reason removed.');
    }
}
