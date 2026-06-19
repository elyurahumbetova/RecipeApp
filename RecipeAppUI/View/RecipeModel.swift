//
//  RecipeModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 13.06.26.
//

import Foundation
import FirebaseFirestore
struct RecipeModel: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let cookingMinute: Int
    let imageURL: String?
    let ingredients: [String]
    let steps: [String]
    let createdAt: Timestamp
    
}

