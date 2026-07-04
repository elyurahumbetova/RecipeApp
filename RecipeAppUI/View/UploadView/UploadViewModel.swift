//
//  UploadViewModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 24.06.26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

@Observable

class UploadViewModel{
    var currentStep: Int = 1
    
    var coverPhotoItem: PhotosPickerItem? = nil
    var coverImage: UIImage? = nil
    var foodName: String = ""
    var descriptionText: String = ""
    var cookingDuration: Double = 35
    var showAlert = false
    
    
    var ingredients : [String] = ["",""]
    var showSuccess: Bool = false
    var steps: [String] = [""]
    var isUploading: Bool = false
    var uploadError: String? = nil  

    
    private let recipeService = RecipeService()
    private let storageService = StorageService()
    
    
    func goToStep2(){
        guard coverImage != nil else{
            showAlert = true
            return
        }
        withAnimation(.easeInOut){
            currentStep = 2
        }
    }
    
    func goToStep1(){
        withAnimation(.easeInOut){
            currentStep = 1
        }
    }

    @MainActor
    func uploadRecipe() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            uploadError = "Zəhmət olmasa yenidən daxil olun"
            return
        }

        isUploading = true
        defer { isUploading = false }   // hər halda sıfırlanır

        let cleanIngredients = ingredients.filter { !$0.isEmpty }
        let cleanSteps = steps.filter { !$0.isEmpty }

        var data: [String: Any] = [
            "title": foodName,
            "description": descriptionText,
            "cookingMinute": Int(cookingDuration),
            "ingredients": cleanIngredients,
            "steps": cleanSteps,
            "createdAt": FieldValue.serverTimestamp(),
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
            print("Upload error:", error)
            uploadError = error.localizedDescription   // İSTİFADƏÇİYƏ GÖSTƏR
        }
    }
}
