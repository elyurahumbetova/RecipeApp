import SwiftUI
import FirebaseFirestore
import Kingfisher
struct HomeContentView: View {
    @State private var text = ""
    @State private var selectedCategory = "All"
    @State private var viewModel = HomeViewModel()
    @Environment(NavigatorCoordinator.self) private var coordinator
    let categories = ["All", "Food", "Drink"]
        
    
    var filteredRecipes: [RecipeModel]
    {
        if text.isEmpty{return viewModel.recipes }
        return viewModel.recipes.filter{ $0.title.localizedCaseInsensitiveContains(text)}
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
                        AppButton(title: LocalizedStringKey(cat), variant: selectedCategory == cat ? .primaryFilled : .secondaryTextFilled, size: .small) {
                            selectedCategory = cat
                        }
                    }
                }
            }
            .padding(24)

            Rectangle()
                .fill(.appForm)
                .frame(height: 5)

            
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                if viewModel.isLoading{
                    ProgressView()
                        .padding(.top,50)
                }else if filteredRecipes.isEmpty{
                    Text("No recipe found")
                        .foregroundStyle(.appSecondaryText)
                        .padding(.top,50)
                    
                }else{
                    LazyVGrid(columns: columns,spacing: 16){
                        
                        ForEach(filteredRecipes){ recipe in
                            let user = viewModel.profiles[recipe.userId ?? ""]
                            VStack(alignment: .leading,){
                                HStack(spacing: 8){
                                    KFImage(URL(string: user?.profileImage ?? ""))
                                        .placeholder {
                                            Color.gray.opacity(0.3)
                                        }
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
                                    Text(user?.userName ?? "Unknown")
                                        .font(.p2)
                                    
                                }
                                RecipeCardView(recipe: recipe)
                                    .clipped()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                coordinator.push(.detailView1(recipe))
                            }
                    
                        }
                    }
                    .padding(.horizontal,16)
                    .padding(.vertical,16)

                }
            Spacer().frame(height: 80)
        }
        .clipped()
        .task {
                await viewModel.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .recipeUploaded)){_ in
            Task{
                await viewModel.refreshRecipe()
            }
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
    .frame(width: 180) 
    .padding()
}
