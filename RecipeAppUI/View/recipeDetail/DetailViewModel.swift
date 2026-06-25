//
//  DetailViewMOdel.swift
//  RecipeAppUI
//
//  Created by Elyura on 24.06.26.
//

import SwiftUI
@Observable
@MainActor
class DetailViewModel{
    var isLoading = false
    var user: UserModel?
    
    private let userService = UserService()
    
    func fetchUser(userId: String ) async{
        isLoading = true
        
        do{
            user = try await userService.fetchUser(by: userId)
            
        }catch{
            print(error)
        }
        isLoading = false
    }
}
