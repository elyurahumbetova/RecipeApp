//
//  Supabase.swift
//  RecipeAppUI
//
//  Created by Elyura on 16.06.26.
//

import Foundation
import Supabase

func makeSupabaseClient() -> SupabaseClient {
    let supabaseURLString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? "MISSING_URL"
    let supabaseKeyString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String ?? "MISSING_KEY"

    print("🔍 SUPABASE_URL:", supabaseURLString)
    print("🔍 SUPABASE_KEY:", supabaseKeyString)

    guard let supabaseURL = URL(string: supabaseURLString) else {
        fatalError("❌ Invalid URL from Info.plist: \(supabaseURLString)")
    }

    return SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: supabaseKeyString
    )
}

let supabase = makeSupabaseClient()
