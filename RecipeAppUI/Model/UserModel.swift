//
//  UserModel.swift
//  RecipeAppUI
//
//  Created by Elyura on 19.06.26.
//

import Foundation

struct UserModel: Codable, CopyWith {
    let userName: String
    var profileImage: String
    enum CodingKeys: String, CodingKey{
        case userName = "username"
        case profileImage
    }
    
}
