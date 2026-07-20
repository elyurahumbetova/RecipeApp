//
//  UserSession.swift
//  RecipeAppUI
//
//  Created by Elyura on 18.07.26.
//

import SwiftUI

@MainActor
@Observable
final class UserStore{
    
    private(set) var users: [String: UserModel] = [:]
   
    func setProfile(id: String,profile: UserModel ){
        users[id] = profile
    }
    
    
    func updateProfile(
        id: String,
        producer: (UserModel) -> UserModel
    ){
        guard let oldProfile = users[id] else {
             return
        }
        users[id] = producer(oldProfile)
    }
    
    
}
