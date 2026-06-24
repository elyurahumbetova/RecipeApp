//
//  AppCoordinator.swift
//  RecipeAppUI
//
//  Created by Elyura on 19.03.26.
//

import SwiftUI

@Observable
class NavigatorCoordinator {
    var path: [AppRoute] = []
    var root: AppRoute = .splash
    var colorScheme: ColorScheme? = nil

    
    func push(_ route: AppRoute) {
        print("🟢 pushing: \(route)")
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func replace(_ route: AppRoute) {
        path.removeLast()
        path.append(route)
    }
    
    func setRoot(_ route: AppRoute) {
        root = route
        path = []
    }
}

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
