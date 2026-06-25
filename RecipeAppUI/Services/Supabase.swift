//
//  Supabase.swift
//  RecipeAppUI
//
//  Created by Elyura on 16.06.26.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? "")!,
  supabaseKey: Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String ?? "",
)
