//
//  LocalizedManager.swift
//  RecipeAppUI
//
//  Created by Elyura on 07.07.26.
//
import SwiftUI

@Observable
class LocalizedManager {
    static let shared = LocalizedManager()

    var currentLang: String {
        didSet {
            UserDefaults.standard.set(currentLang, forKey: "app_language")
        }
    }

    init() {
        currentLang = UserDefaults.standard.string(forKey: "app_language") ?? "en"
    }
    func t(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLang, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
