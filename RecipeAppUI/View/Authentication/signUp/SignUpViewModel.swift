//
//  SignUpViewModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 24.06.26.
//
import FirebaseAuth
import SwiftUI

@Observable
class SignUpViewModel {
    var email = ""
    var password = ""
    var userName = ""
    var errorMessage = ""
    var isLoading = false
    
    private let userService = UserService()
    
    var hasMinLength: Bool { password.count >= 8 }
    var hasNumber: Bool { password.contains(where: \.isNumber) }
    var isFormValid: Bool { hasMinLength && hasNumber && !email.isEmpty }
    
    @MainActor
    func register() async -> User? {
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await userService.signUp(email: email, password: password, username: userName)
            isLoading = false
            return user
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }
}
