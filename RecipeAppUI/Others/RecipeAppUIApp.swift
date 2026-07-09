//
//  RecipeAppUIApp.swift
//  RecipeAppUI
//
//  Created by Elyura on 09.03.26.
//

import SwiftUI
import FirebaseCore

@main
struct RecipeAppUIApp: App {
    init() {
            URLCache.shared = URLCache(
                memoryCapacity: 50 * 1024 * 1024,
                diskCapacity: 200 * 1024 * 1024,    
                diskPath: "imageCache"
            )
        }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            RootView()
                
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,

   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    return true

  }

}

