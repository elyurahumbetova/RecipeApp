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
    var foodType: FoodType = .food
    private let recipeService = RecipeService()
    private let storageService = StorageService()
    
    var foodNameError: String? = nil
    var descriptionError: String? = nil
    var ingredientError: Set<Int> = []
    var stepError: Set<Int> = []
    
    private let localization = LocalizedManager.shared
    
    
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

    
    
    @discardableResult
    func addIngredient() -> Int{
        var newIndex = 0
        withAnimation(.easeInOut(duration: 0.25)){
            ingredients.append("")
            newIndex = ingredients.count - 1
        }
        return newIndex
    }
    
    @discardableResult
    func addSteps() -> Int{
        var newIndex = 0
        withAnimation(.easeInOut(duration: 0.25)){
            
            
            steps.append("")
            newIndex = steps.count - 1
        }
        return newIndex 
    }
    
    func removeIngredient(at index: Int){
        guard ingredients.count > 1,ingredients.indices.contains(index) else{
            return
        }
        
        ingredients.remove(at: index)
    }
    
    func removeStep(at index: Int) {
        guard steps.count > 1 , steps.indices.contains(index) else{
            return
        }
        
        steps.remove(at: index)
    }
    
    
    func nextIngredientFocus(after index: Int) -> Int{
        if index == ingredients.count - 1{
            return addIngredient()
        }else{
           return index + 1
        }
    }
    
    func nextStepFocus(after index: Int) -> Int{
        if index == steps.count - 1{
            return addSteps()
        }else{
            return index + 1 
        }
    }
    
    @discardableResult
    func validationStep1() -> Bool{
        var isValid = true
        
        if foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            foodNameError = localization.t("This field is required")
            isValid = false
        }else{
            foodNameError = nil
        }
        
        if descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            descriptionError = localization.t("This field is required")
            isValid = false
        }else{
            descriptionError = nil
        }
        
        if coverImage == nil {
            showAlert = true
            isValid = false
        }
        return isValid
    }
    
    @discardableResult
    func validationStep2() -> Bool{
        ingredientError.removeAll()
        stepError.removeAll()
        
        for (index,ingredient ) in ingredients.enumerated(){
            if ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                ingredientError.insert(index)
            }
        }
        for (index,step ) in steps.enumerated(){
            if step.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                stepError.insert(index)
            }
        }
        
        return ingredientError.isEmpty && stepError.isEmpty

        
    }
    
    
    @MainActor
    func uploadRecipe() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            uploadError = "Please try again"
            return
        }

        
        let step1Valid = validationStep1()
        let step2Valid = validationStep2()
        guard step1Valid, step2Valid else{
            uploadError = localization.t("Pleas fill all of the fields")
            if !step1Valid{
                currentStep = 1
            }else{
                currentStep = 2
            }
            return
        }
        
        
        
        isUploading = true
        defer { isUploading = false }

        let cleanIngredients = ingredients.filter { !$0.isEmpty }
        let cleanSteps = steps.filter { !$0.isEmpty }

        var data: [String: Any] = [
            "title": foodName,
            "description": descriptionText,
            "cookingMinute": Int(cookingDuration),
            "ingredients": cleanIngredients,
            "steps": cleanSteps,
            "createdAt": FieldValue.serverTimestamp(),
            "userId": uid,
            "type": foodType.rawValue
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
            uploadError = error.localizedDescription
        }
    }
}
