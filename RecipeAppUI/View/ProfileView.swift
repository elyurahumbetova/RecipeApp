import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import Supabase

struct Recipe: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let time: String
    var isLiked: Bool = false
}

struct StatItem: View {
    let value: Int
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value.formatted(.number))
                .font(.h2)
                .foregroundColor(.appMainText)
            Text(label)
                .font(.s)               .foregroundColor(.appSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}



struct ProfileTabPicker: View {
    
    @Binding var selected: Int
    let tabs = ["Recipes", "Liked"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selected = i
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text(tabs[i])
                            .font(.h3)
                            .foregroundColor(selected == i ? .appPrimary : .appSecondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)

                        Rectangle()
                            .fill(selected == i ? .appPrimary : Color.clear)
                            .frame(height: 2)
                    }
                }
            }
        }
        .overlay(
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}


struct ProfileView: View {
    @State private var recipes: [RecipeModel] = []
    @State private var isLoading  = false
    @State private var selectedTab = 0
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var userName = ""
    @State private var email = ""
    @State private var likedRecipes: [RecipeModel] = []
    @State private var isUploadinghoto = false
    @State private var profileImageURL = ""
    @Environment(NavigatorCoordinator.self) var coordinator
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            Circle().fill(.appForm)
                            if let image = selectedImage {

                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())

                            } else if !profileImageURL.isEmpty {

                                AsyncImage(url: URL(string: profileImageURL + "?v=\(UUID().uuidString)")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(Circle())

                            } else {

                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.appSecondaryText)
                            }
                        }
                    }
                    .frame(width: 90, height: 90)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                                uploadProfileImage(uiImage)
                            }
                        }
                    }
                    
                    Text(userName.isEmpty ? "Loading..." : userName)
                        .font(.h2)
                        .foregroundColor(.appMainText)
                }
                .padding(.top, 8)
                
                
                HStack {
                    StatItem(value: 32,   label: "Recipes")
                    Rectangle().fill(Color(.systemGray4)).frame(width: 1, height: 36)
                    StatItem(value: 782,  label: "Following")
                    Rectangle().fill(Color(.systemGray4)).frame(width: 1, height: 36)
                    StatItem(value: 1287, label: "Followers")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                
                ProfileTabPicker(selected: $selectedTab)
                    .padding(.top, 12)
                
                
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if selectedTab == 0 {
                    if recipes.isEmpty {
                        VStack{
                            Spacer()
                            Text("No recipes yet")
                                .foregroundStyle(.appSecondaryText)
                                .padding(.top, 40)
                            Spacer()
                        }
                        
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns) {
                                ForEach(recipes) { recipe in
                                    RecipeCardView(recipe: recipe)
                                }
                            }
                            .padding(16)
                        }
                    }
                } else {
                    if likedRecipes.isEmpty {
                        Text("No liked recipes yet")
                            .foregroundStyle(.appSecondaryText)
                            .padding(.top, 40)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns) {
                                ForEach(likedRecipes) { recipe in
                                    RecipeCardView(recipe: recipe)
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        coordinator.push(.settingView)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.appSecondaryText)
                    }
                }
            }
            .task {
                isLoading = true
                await fetchUser()
                await fetchMyRecipes()
                await fetchLikedRecipes()
                isLoading = false
            }
            .onChange(of: selectedTab) { _, tab in
                if tab == 1 {
                    Task { await fetchLikedRecipes()
                        
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .recipeUploaded)) { _ in
                Task {
                    await fetchMyRecipes()
                }
            }
        }
    }
    
    func fetchMyRecipes() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        do {
            let doc = try await db.collection("createrecipes")
                .document(uid)
                .getDocument()
            
            guard doc.exists else {
                print("❌ createrecipes document yoxdur")
                await MainActor.run { recipes = [] }
                return
            }
            
            let recipeIds = doc.data()?["recipes"] as? [String] ?? []
            print("📋 Recipe IDs:", recipeIds)  // ← burda ID-lər çıxırmı?
            
            guard !recipeIds.isEmpty else {
                await MainActor.run { recipes = [] }
                return
            }
            
            let snapshot = try await db.collection("recipes")
                .whereField(FieldPath.documentID(), in: recipeIds)
                .getDocuments()
            
            print("📦 Gələn recipe sayı:", snapshot.documents.count)  // ← 0-dırmı?
            
            let items = snapshot.documents.compactMap { doc -> RecipeModel? in
                do {
                    return try doc.data(as: RecipeModel.self)
                } catch {
                    print("❌ Decode xətası:", error)  // ← decode problemi varsa görünər
                    return nil
                }
            }
            
            await MainActor.run { recipes = items }
            
        } catch {
            print("❌ fetchMyRecipes error:", error)
        }
    }
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ currentUser nil-dir - login yoxdur")
            return
        }
        
        print("✅ UID:", uid)
        
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("profile").document(uid).getDocument()
            print("📄 Data:", snapshot.data() ?? [:])
            
            if let data = snapshot.data() {
                await MainActor.run {
                    userName = data["username"] as? String ?? ""
                    email    = data["email"]    as? String ?? ""
                    profileImageURL = data["profileImage"] as? String ?? ""
                }
            }
        } catch {
            print("❌ Firestore xətası:", error)
        }
    }
    func fetchLikedRecipes() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        do {
            let doc = try await db.collection("liked")
                .document(uid)
                .getDocument()
            
            let recipeIds = doc.data()?["recipes"] as? [String] ?? []
            
            guard !recipeIds.isEmpty else {
                await MainActor.run {
                    likedRecipes = []
                }
                return
            }
            
            let snapshot = try await db.collection("recipes")
                .whereField(FieldPath.documentID(), in: recipeIds)
                .getDocuments()
            
            let items = snapshot.documents.compactMap {
                try? $0.data(as: RecipeModel.self)
            }
            
            await MainActor.run {
                likedRecipes = items
            }
            
        } catch {
            print("Liked fetch error:", error)
        }
    }
    func uploadProfileImage(_ image: UIImage) {

        guard let uid = Auth.auth().currentUser?.uid,
            let imageData = image.jpegData(compressionQuality: 0.8)
        else { return }

        Task {
            do {
                let fileName = "\(uid).jpg"
                try await supabase.storage
                    .from("profiles")
                    .upload(fileName, data: imageData, options: .init(upsert: true))
                let publicImageUrl = try supabase.storage
                    .from("profiles")
                    .getPublicURL(path: fileName)

                try await Firestore.firestore()
                    .collection("profile")
                    .document(uid)
                    .setData([
                        "profileImage": publicImageUrl.absoluteString
                    ], merge: true)
                await MainActor.run {
                    profileImageURL = publicImageUrl.absoluteString
                }
                await fetchUser()
            } catch {
                print("❌ Upload error:", error)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(NavigatorCoordinator())
}
