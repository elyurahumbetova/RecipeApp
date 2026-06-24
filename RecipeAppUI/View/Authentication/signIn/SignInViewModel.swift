//
//  SignInModelView.swift
//  RecipeAppUI
//
//  Created by Elyura on 24.06.26.
//

import SwiftUI
import FirebaseAuth

@Observable
@MainActor

class SignInViewModel{
    var email = ""
    var passwords = ""
    var errorMessage: String = ""
    var isLoading = false
    
    private let userService = UserService()
    
    func login() async -> User?{
        isLoading = true
        errorMessage = ""
        do{
            let user = try await userService.signIn(email: email, password: passwords)
            isLoading = false
            return user
        }catch{
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
        
    }
}
