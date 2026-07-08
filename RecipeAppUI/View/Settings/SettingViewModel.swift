//
//  SettingViewModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 07.07.26.
//

import SwiftUI
import FirebaseAuth

@Observable

class SettingViewModel {
   
    
    var showLogoutAlert = false
     
    func requestLogout() {
        showLogoutAlert = true
        
    }
    
    func cancelLogout () {
        showLogoutAlert = false
    }
    
   @discardableResult
    func logout(
        currentColorScheme: String,
        userCoordinator: UserCoordinator,
        coordinator: NavigatorCoordinator
        
    ) -> String {
        do{
            try Auth.auth().signOut()
            
            let userId = userCoordinator.user?.uid ?? ""
            
            UserDefaults.standard.set(currentColorScheme, forKey: "appColorScheme_\(userId)")
            userCoordinator.user = nil
            coordinator.setRoot(.signIn)
        }catch{
            print(error)
        }
        return "system"
    }
}


