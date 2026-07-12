//
//  RecipeModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 13.06.26.
//

import Foundation
import FirebaseFirestore

struct RecipeModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let cookingMinute: Int
    let imageURL: String?
    let ingredients: [String]
    let steps: [String]
    let createdAt: Timestamp
    let userId: String?
    var type: FoodType
    
}

enum FoodType: String, Codable,CaseIterable {
    case food = "food"
    case drink = "drink"
    
    var title: String {
        switch self{
        case .food : return LocalizedManager.shared.t("Food")
        case .drink: return LocalizedManager.shared.t("Drink")
        }
    }
}
