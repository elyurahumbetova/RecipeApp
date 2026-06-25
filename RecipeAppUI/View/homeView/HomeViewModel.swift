//
//  HomeViewModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 23.06.26.
//

import SwiftUI

@Observable
@MainActor
class HomeViewModel{
    var recipes: [RecipeModel] = []
    var profiles: [String: UserModel] = [:]
    var isLoading = false
    private var hasLoaded = false
    
    var recipeService = RecipeService()
    
    func loadData() async{
        
        guard !hasLoaded else {return }
        isLoading = true

        recipes = await fetchRecipes()
        profiles = await fetchProfiles()
        
        isLoading = false
    }
    
    func refreshRecipe() async{
        do{
            recipes = try await recipeService.fetchAllRecipes()
        }catch{
            print(error)
        }
    }
    
    private func fetchRecipes() async -> [RecipeModel]{
        do{
            return (try? await RecipeService().fetchAllRecipes()) ?? []
        }
    }
    
    private func fetchProfiles() async -> [String: UserModel]{
        do{
            return try await UserService().fetchProfiles()
        }catch{
            print(error)
            return [:]
        }
    }
    
}
