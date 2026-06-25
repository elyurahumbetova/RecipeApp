//
//  AppRoute.swift
//  RecipeAppUI
//
//  Created by Elyura on 19.03.26.
//
import UIKit

enum AppRoute {
    case splash
    case onBoarding
    case signIn
    case signUp
    case home
    case uploadView
    case uploadView2(foodName: String, description: String, cookingDuration: Int, image: UIImage?)
    case settingView
    case detailView1(RecipeModel)
}

extension AppRoute: Hashable {
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.splash, .splash): return true
        case (.onBoarding, .onBoarding): return true
        case (.signIn, .signIn): return true
        case (.signUp, .signUp): return true
        case (.home, .home): return true
        case (.settingView, .settingView): return true
        case (.uploadView, .uploadView): return true
        case (.uploadView2(let a, let b, let c, _), .uploadView2(let d, let e, let f, _)):
            return a == d && b == e && c == f
        case (.detailView1(let r1), .detailView1(let r2)):
               return r1.id == r2.id
           default: return false        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .splash: hasher.combine(0)
        case .onBoarding: hasher.combine(1)
        case .signIn: hasher.combine(2)
        case .signUp: hasher.combine(3)
        case .home: hasher.combine(4)
        case .uploadView: hasher.combine(5)
        case .uploadView2(let name, let desc, let mins, _):
            hasher.combine(6)
            hasher.combine(name)
            hasher.combine(desc)
            hasher.combine(mins)
        case .settingView: hasher.combine(7)
        case .detailView1(let recipe):
            hasher.combine(8)
            hasher.combine(recipe.id)
        }
    }
}
