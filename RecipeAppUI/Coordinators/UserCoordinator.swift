//
//  UserCoordinator.swift
//  RecipeAppUI
//
//  Created by Elyura on 23.03.26.
//

import FirebaseAuth
import SwiftUI

@Observable
class UserCoordinator {
    var user: FirebaseAuth.User? = nil
    var isCheckingAuth: Bool = true
    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            self.isCheckingAuth = false

            
        }
    }
}
