//
//  SignIn.swift
//  RecipeAppUI
//
//  Created by Elyura on 09.03.26.
//

import SwiftUI
import FirebaseAuth
 

struct SignIn: View {
    @Environment(NavigatorCoordinator.self) var coordinator
    @Environment(UserCoordinator.self) var userCoordinator
    
    @State private var email = ""
    @State private var passwords = ""
    @State private var errorMessage: String = ""
  
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Welcome Back!")
                .font(.h1)
                .foregroundStyle(.appMainText)
                .padding(.top, 107)
            
            Text("Please enter your account here")
                .font(.p2)
                .foregroundStyle(.appSecondaryText)
                .padding(.bottom, 32)
            
            AppTextField(type: .email, text: $email)
                .padding(.bottom, 16)
                .autocapitalization(.none)
            AppTextField(type: .password, text: $passwords)
                .padding(.bottom, 24)
            
            HStack {
                Spacer()
                Text("Forgot Password?")
                    .font(.p2)
                    .foregroundStyle(.appMainText)
            }
            .padding(.bottom, 72)
            
            
            if !errorMessage.isEmpty{
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            AppButton(title: "Login", variant: .primaryFilled, size: .regular) {
                login()

            }
            
            Text("Or continue with")
                .font(.p2)
                .foregroundStyle(.appSecondaryText)
            
            AppButton(title: "Google", variant: .secondaryFilled, size: .regular, icon: "Google") {}
            
            HStack {
                Text("Don't have any account?")
                    .font(.p2)
                    .foregroundStyle(.appMainText)
                
                Button {
                    coordinator.push(.signUp)
                } label: {
                    Text("Sign Up")
                        .foregroundStyle(.green)
                        .font(.h3)
                }
            }
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.appMainText)
                }
            }
        }
    }
    // Login funksiyasında:
    func login() {
        Auth.auth().signIn(withEmail: email, password: passwords) { result, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let user = result?.user else { return }
            
            DispatchQueue.main.async {
                self.userCoordinator.user = user
                
                if let savedTheme = UserDefaults.standard.string(
                    forKey: "appColorScheme_\(user.uid)"
                ) {
                    self.appColorScheme = savedTheme
                }
                
                self.coordinator.push(.home)
            }
        }
    }
}


#Preview {
    NavigationStack {
        SignIn()
            .environment(NavigatorCoordinator())
            .environment(UserCoordinator())
    }
}
