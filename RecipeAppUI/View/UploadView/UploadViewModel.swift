//
//  UploadViewModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 24.06.26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable

class UploadViewModel{
    var ingredients : [String] = ["",""]
    var showSuccess: Bool = false
    var steps: [String] = [""]
    var isUploading = false
    
    private let recipeService = RecipeService()
    private let storageService = StorageService()
    
    @MainActor
    func uploadRecipe(
            foodName: String,
            descriptionText: String,
            cookingDuration: Int,
            coverImage: UIImage?
        ) async {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("❌ UID yoxdur")
                return
            }
            
            isUploading = true
            
            let cleanIngredients = ingredients.filter { !$0.isEmpty }
            let cleanSteps = steps.filter { !$0.isEmpty }
            
            var data: [String: Any] = [
                "title": foodName,
                "description": descriptionText,
                "cookingMinute": cookingDuration,
                "ingredients": cleanIngredients,
                "steps": cleanSteps,
                "createdAt": Timestamp(),
                "userId": uid
            ]
            
            do {
                if let image = coverImage {
                    let imageURL = try await storageService.uploadRecipeImage(image)
                    data["imageURL"] = imageURL
                }
                
                try await recipeService.createRecipe(data: data, uid: uid)
                
                NotificationCenter.default.post(name: .recipeUploaded, object: nil)
                showSuccess = true
            } catch {
                print("❌ Upload error:", error)
            }
            
            isUploading = false
        }
}
