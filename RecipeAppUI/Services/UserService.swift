//
//  UserService.swift
//  RecipeAppUI
//
//  Created by Elyura on 22.06.26.
//

import FirebaseFirestore
import FirebaseAuth

struct UserService{
    private let db = Firestore.firestore()
    
    func fetchProfile(uid : String) async throws -> (userName: String, email: String, profileImageURL: String) {
        let snapshot = try await db.collection("profile").document(uid).getDocument()
        let data = snapshot.data() ?? [:]
        
        return (
            userName: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            profileImageURL: data["profileImage"] as? String ?? ""
            
        )
    }
    func updateProfileImage(uid: String, url: String) async throws {
        try await db.collection("profile").document(uid).setData([
            "profileImage": url
        ], merge: true)
    }
    func fetchProfiles() async throws -> [String: UserModel]{
        do {
            let snapshot = try await Firestore.firestore()
                .collection("profile")
                .getDocuments()
            
            var temp: [String: UserModel] = [:]
            
            for doc in snapshot.documents {
                let data = doc.data()
                
                temp[doc.documentID] = UserModel(
                    userName: data["username"] as? String ?? "",
                    profileImage: data["profileImage"] as? String ?? ""
                )
            }
            
            return temp
        }
    }
    
    func fetchUser(by uid: String) async throws -> UserModel{
        let snapshot =  try await db.collection("profile").document(uid).getDocument()
        return try snapshot.data(as: UserModel.self)
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    func signUp(email: String, password: String, username: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await db.collection("profile").document(result.user.uid).setData([
            "uid": result.user.uid,
            "username": username,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ])
        return result.user
    }
}
