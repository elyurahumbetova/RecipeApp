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
    
    init(){
        currentLang = UserDefaults.standard.string(forKey: "app_language") ?? "az"
        Bundle.setLanguage(currentLang)
    }
    
    var currentLang: String {
        didSet{
            UserDefaults.standard.set(currentLang, forKey: "app_language")
            Bundle.setLanguage(currentLang)
        }
    }
    
    
}

private var bundleKey: UInt8 = 0

extension Bundle {
    static func setLanguage(_ language : String){
        object_setClass(Bundle.main, BundleEx.self)
        objc_setAssociatedObject(Bundle.main, &bundleKey, language, .OBJC_ASSOCIATION_RETAIN)
    }
    
}
private class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let language = objc_getAssociatedObject(self, &bundleKey) as? String,
              let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else{
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
