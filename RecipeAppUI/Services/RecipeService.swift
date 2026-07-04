//
//  RecipeService.swift
//  RecipeAppUI
//
//  Created by Elyura on 22.06.26.
//

import FirebaseFirestore

struct RecipeService{
    private let db = Firestore.firestore()
    private let fieldKey = "recipes"
    
    func fetchRecipeIds(from collection: String, uid: String) async throws -> [String]{
        let doc = try await db.collection(collection).document(uid).getDocument()
        return doc.data()?["recipes"] as? [String] ?? []
    }
    
    func fetchRecipes(ids: [String]) async throws -> [RecipeModel]{
        guard !ids.isEmpty else{ return []}
        let snapshot = try await db.collection("recipes")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments()
        return snapshot.documents.compactMap{ doc -> RecipeModel? in
            do{
                return try doc.data(as: RecipeModel.self)
                
            }catch{
                return nil
            }
        }
    }
    func fetchAllRecipes() async throws -> [RecipeModel] {
        let snapshot = try await db
            .collection("recipes")
            .order(by: "createdAt",descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: RecipeModel.self)
        }
    }
    func createRecipe(data: [String: Any], uid: String) async throws {
            let recipeRef = db.collection("recipes").document()
            try await recipeRef.setData(data)
            
            try await db.collection("createrecipes")
                .document(uid)
                .setData(
                    ["recipes": FieldValue.arrayUnion([recipeRef.documentID])],
                    merge: true
                )
        }
    
    func deleteRecipe(recipeId: String, uid: String) async throws {
        try await db.collection("recipes")
            .document(recipeId)
            .delete()
        try await db.collection("createrecipes")
            .document(uid)
            .updateData([
                "recipes": FieldValue.arrayRemove([recipeId])
             ])
    }
}
