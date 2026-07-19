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
    var currentUser: UserModel?
    var currentProfileImage: UIImage?
    func updateProfileImage(
        image: UIImage,
        url: String? = nil
    ){
        currentProfileImage = image
        guard let url else { return}
        if var user = currentUser {
            user.profileImage = url
            currentUser = user
        }
    }
}
