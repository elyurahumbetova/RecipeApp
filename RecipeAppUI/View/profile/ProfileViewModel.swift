//
//  ProfileViewModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 22.06.26.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

@Observable
@MainActor

class ProfileViewModel{
    var recipes: [RecipeModel] = []
    var likedRecipes: [RecipeModel] = []
    var isLiked = false
    var userName = ""
    var email = ""
    var profileImageURL = ""
    var selectedImage: UIImage?
    var isLoading = false
    var profile: UserModel?
    
    private let userService = UserService()
    private let recipeService = RecipeService()
    private let storageService = StorageService()
    
    func loadInitialData() async{
        isLoading = true
        await fetchMyRecipes()
        await fetchUser()
        await fetchLikedRecipes()
        isLoading = false
    }
    
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        do {
            let fetchedProfile = try await userService.fetchProfile(uid: uid)

            profile = UserModel(
                userName: fetchedProfile.userName,
                profileImage: fetchedProfile.profileImageURL
            )

            userName = fetchedProfile.userName
            email = fetchedProfile.email
            profileImageURL = fetchedProfile.profileImageURL

        } catch {
            print(error)
        }
    }
    func fetchMyRecipes() async{
        guard let uid = Auth.auth().currentUser?.uid else { return }
                
                do {
                    let ids = try await recipeService.fetchRecipeIds(from: "createrecipes", uid: uid)
                    guard !ids.isEmpty else{
                        recipes = []
                        return
                    }
                    recipes = try await recipeService.fetchRecipes(ids: ids)
                }catch{
                    print(error)
                }
    }
    func fetchLikedRecipes() async{
        guard let uid = Auth.auth().currentUser?.uid else{ return}
        
        do{
            let ids = try await recipeService.fetchRecipeIds(from: "liked", uid: uid)
            guard !ids.isEmpty else{
                likedRecipes = []
                return
            }
            likedRecipes = try await recipeService.fetchRecipes(ids: ids)
        }catch{
            print(error)
        }
        
         
    }
    func loadSelectedImage(_ item: PhotosPickerItem?) async -> UIImage? {
        guard let item else {
            return nil
        }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                return nil
            }

            selectedImage = image
            return image
        } catch {
            print(error)
            return nil
        }
    }
    
    func uploadProfileImage(_ image: UIImage) async -> String?{
        guard let uid = Auth.auth().currentUser?.uid else{return nil}
        do{
            let url = try await storageService.uploadProfileImage(uid: uid, image:image)
            try await userService.updateProfileImage(uid: uid, url: url)
            profileImageURL = url
            return url
            } catch {
                print(error)
                return nil
            }
        }
    
    func deleteRecipe(_ recipe: RecipeModel) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let recipeId = recipe.id else {
            return
        }

        let previousRecipes = recipes
        let previousLikedRecipes = likedRecipes
        
        recipes.removeAll{
            $0.id == recipeId
        }
        likedRecipes.removeAll{
            $0.id == recipeId
        }
        NotificationCenter.default.post(
            name: .recipeDeleted,
            object: recipeId
        )
        
        
        do {
            try await recipeService.deleteRecipe(
                recipeId: recipeId,
                uid: uid
            )

        } catch {
            
            
            recipes = previousRecipes
            likedRecipes = previousLikedRecipes
            
            NotificationCenter.default.post(
                name: .recipeDeleteFailed,
                object: recipeId
            )
            print(error)
        }
    }
    
}
