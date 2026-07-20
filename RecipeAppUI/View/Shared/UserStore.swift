//
//  UserSession.swift
//  RecipeAppUI
//
//  Created by Elyura on 18.07.26.
//

import SwiftUI

@MainActor
@Observable

final class UserSession{
    
    @available(*, deprecated, message: "Use users dictionary with id to read profile image with url")
    var currentProfileImage: UIImage?
    
    private(set) var users: [String: UserModel] = [:]
    
    func updateProfile(id: String, producer: (UserModel) -> UserModel) {
        guard let oldProfile = users[id] else { return }
        let newProfile = producer(oldProfile)
        users.updateValue(newProfile, forKey: id)
    }
    
    @available(*, deprecated, message: "use updateProfile method directly")
    func updateProfileImage(
        image: UIImage,
        url: String? = nil
    ){
        updateProfile(id: "5") { profile in
            return UserModel(
                userName: profile.userName,
                profileImage: url ?? ""
            )
        }
        
        updateProfile(id: "5") { profile in
            return UserModel(
                userName: "Elyura",
                profileImage: profile.profileImage,
            )
        }
    }
}
