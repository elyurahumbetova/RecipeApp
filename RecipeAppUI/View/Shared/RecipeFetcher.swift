//
//  RecipeFetcher.swift
//  RecipeAppUI
//
//  Created by Elyura on 15.06.26.
//

import Foundation
import FirebaseFirestore
func fetchRecipes() async throws -> [RecipeModel]{
        let snapshot = try await Firestore.firestore()
            .collection("recipes")
            .order(by: "createdAt",descending: true)
            .getDocuments()
        return snapshot.documents.compactMap {
            try? $0.data(as: RecipeModel.self)
         }
    
}
extension Notification.Name{
    static let recipeUploaded = Notification.Name("recipeUploaded")
}
