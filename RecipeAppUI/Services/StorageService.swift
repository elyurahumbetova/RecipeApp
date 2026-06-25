//
//  StorageService.swift
//  RecipeAppUI
//
//  Created by Elyura on 22.06.26.
//

import UIKit
import Supabase

struct StorageService {
    func uploadProfileImage(uid: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data conversion failed"])
        }
        
        let fileName = "\(uid).jpg"
        try await supabase.storage
            .from("profiles")
            .upload(fileName, data: imageData, options: .init(upsert: true))
        
        let publicURL = try supabase.storage
            .from("profiles")
            .getPublicURL(path: fileName)
        
        return publicURL.absoluteString
    }
    
    func uploadRecipeImage(_ image: UIImage) async throws -> String {
           guard let imageData = image.jpegData(compressionQuality: 0.8) else {
               throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data conversion failed"])
           }
           
           let fileName = "\(UUID().uuidString).jpg"
           try await supabase.storage
               .from("recipes")
               .upload(fileName, data: imageData)
           
           let publicURL = try supabase.storage
               .from("recipes")
               .getPublicURL(path: fileName)
           
           return publicURL.absoluteString
       }
}
