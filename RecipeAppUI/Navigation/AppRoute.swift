//
//  AppRoute.swift
//  RecipeAppUI
//
//  Created by Elyura on 19.03.26.
//
import UIKit

enum AppRoute : Hashable {
    case splash
    case onBoarding
    case signIn
    case signUp
    case home
    case uploadView
   
    case settingView
    case detailView1(RecipeModel)
}
