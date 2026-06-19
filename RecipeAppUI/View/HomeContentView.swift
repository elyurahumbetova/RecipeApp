import SwiftUI
import FirebaseFirestore
struct HomeContentView: View {
    @State private var text = ""
    @State private var selectedDirection = "Left"
    @State private var selectedCategory = "All"
    @State private var profiles: [String: UserModel] = [:]
    let categories = ["All", "Food", "Drink"]
    
    let tabs = ["Left", "Right"]
    @State private var recipes: [RecipeModel] = []
    @State private var isLoading = false

    var filteredRecipes: [RecipeModel]
    {
        if text.isEmpty{return recipes }
        return recipes.filter{ $0.title.localizedCaseInsensitiveContains(text)}
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                SearchField(text: $text)
                Text("Category")
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                HStack(spacing: 16) {
                    ForEach(categories, id: \.self) { cat in
                        AppButton(title: cat, variant: selectedCategory == cat ? .primaryFilled : .secondaryTextFilled, size: .small) {
                            selectedCategory = cat
                        }
                    }
                }
            }
            .padding(24)

            Rectangle()
                .fill(.appForm)
                .frame(height: 5)

            VStack {
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        Button {
                            selectedDirection = tab
                        } label: {
                            VStack {
                                Text(tab)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 37)
                                    .foregroundStyle(
                                        selectedDirection == tab ? .appMainText : .appOutline
                                    )
                                Rectangle()
                                    .fill(selectedDirection == tab ? .appPrimary : Color.clear)
                                    .frame(height: 3)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                if isLoading{
                    ProgressView()
                        .padding(.top,50)
                }else if filteredRecipes.isEmpty{
                    Text("No recipe found")
                        .foregroundStyle(.appSecondaryText)
                        .padding(.top,50)
                    
                }else{
                    LazyVGrid(columns: columns,spacing: 16){
                        
                        ForEach(filteredRecipes){ recipe in
                            let user = profiles[recipe.userId ?? ""]
                            VStack(alignment: .leading,){
                                HStack(spacing: 8){
                                    AsyncImage(url: URL(string: user?.profileImage ?? "")) { image in
                                                    image.resizable()
                                                } placeholder: {
                                                    Color.gray.opacity(0.3)
                                                }
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())

                                                Text(user?.userName ?? "Unknown")
                                                    .font(.p2)
                                    
                                }
                                RecipeCardView(recipe: recipe)
                                    .clipped()
                            }
                            
                        }
                    }
                    .padding(.horizontal,16)
                    .padding(.vertical,16)

                }
                
                
                
            }

            Spacer().frame(height: 80)
        }.clipped()
            .task {
                isLoading = true

                async let recipesTask = fetchRecipes()
                async let profilesTask: () = fetchProfiles()

                recipes = (try? await recipesTask) ?? []
                await profilesTask

                isLoading = false
            }
        .onReceive(NotificationCenter.default.publisher(for: .recipeUploaded)){_ in
            Task{
                isLoading = true
                recipes = (try? await fetchRecipes()) ?? []
                isLoading = false 
            }
        }
    }
    func fetchProfiles() async {
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

            await MainActor.run {
                profiles = temp
            }

        } catch {
            print("❌ profile fetch error:", error)
        }
    }
   
}
#Preview {
    RecipeCardView(recipe: RecipeModel(
        id: "1",
        title: "Pancake",
        description: "Delicious pancake",
        cookingMinute: 30,
        imageURL: "https://olo-images-live.imgix.net/cb/cbe0798e0b9e4bbbb7391c96da4d9010.jpg",
        ingredients: ["flour", "egg"],
        steps: ["Mix", "Cook"],
        createdAt: Timestamp(),
        userId: "sdknaldk"
    ))
    .frame(width: 180) // ← grid-dəki kimi dar et
    .padding()
}
