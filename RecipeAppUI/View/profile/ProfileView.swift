import SwiftUI
import PhotosUI
import Kingfisher

struct StatItem: View {
    let value: Int
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value.formatted(.number))
                .font(.h2)
                .foregroundColor(.appMainText)
            Text(label)
                .font(.s)
                .foregroundColor(.appSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}



struct ProfileTabPicker: View {
    
    @Binding var selected: Int
    let tabs: [String] = ["Recipes", "Liked"]
    @State private var localization = LocalizedManager.shared


    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selected = i
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text(localization.t(tabs[i]))
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
    @State private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    @State private var selectedItem: PhotosPickerItem?
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var localization = LocalizedManager.shared

    
    @Environment(NavigatorCoordinator.self) var coordinator
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                Circle().fill(.appForm)
                                if let image = viewModel.selectedImage {
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                    
                                } else if !viewModel.profileImageURL.isEmpty {
                                    
                                    
                                    KFImage(URL(string: viewModel.profileImageURL))
                                        .placeholder{
                                            ProgressView()
                                        }
                                        .resizable()
                                        .scaledToFill()
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
                                await viewModel.handlePhotoSelection(newItem)
                            }
                        }
                        
                        Text(viewModel.userName.isEmpty ? localization.t("Loading...") : viewModel.userName)
                            .font(.h2)
                            .foregroundColor(.appMainText)
                    }
                    .padding(.top, 8)
                    
                    
                    HStack {
                        StatItem(value: 32,   label: localization.t("Recipes"));
                        Rectangle().fill(Color(.systemGray4)).frame(width: 1, height: 36);
                        StatItem(value: 782,  label: localization.t("Following"));
                        Rectangle().fill(Color(.systemGray4)).frame(width: 1, height: 36);
                        StatItem(value: 1287, label: localization.t("Followers"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    
                    ProfileTabPicker(selected: $selectedTab)
                        .padding(.top, 12)
                    
                    
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if selectedTab == 0 {
                        recipeGrid(recipes: viewModel.recipes, empthyText: localization.t("No recipes yet"))
                    } else {
                        recipeGrid(recipes: viewModel.likedRecipes, empthyText: localization.t("No liked recipes yet"))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(localization.t("My Profile"))
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
                await viewModel.loadInitialData()
            }
            .onChange(of: selectedTab) { _, tab in
                if tab == 1 {
                    Task { await
                        viewModel.fetchLikedRecipes()
                        
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .recipeUploaded)) { _ in
                Task {
                    await viewModel.fetchMyRecipes()
                }
            }
        }
        
    }
    @ViewBuilder
    private func recipeGrid(recipes: [RecipeModel], empthyText: String) -> some View{
        if recipes.isEmpty{
            VStack{
                Spacer()
                Text(empthyText)
                    .foregroundStyle(.appSecondaryText)
                    .padding(.top, 40)
                Spacer()
            }
            }else {
                    LazyVGrid(columns: columns){
                        ForEach(recipes){ recipe in
                            RecipeCardView(recipe: recipe)
                                .contentShape(Rectangle())
                                .onTapGesture{
                                    coordinator.push(.detailView1(recipe))
                                }
                                .contextMenu{
                                    Button(role: .destructive){
                                        Task{
                                            await viewModel.deleteRecipe(recipe)
                                        }
                                        } label: {
                                            Label(localization.t("Delete"),systemImage: "trash")
                                        }
                                    }
                                
                            
                        }
                    }
                    .padding(16)
                }
            }
        }
    
    
    
    



//#Preview {
//    ProfileView()
//        .environment(NavigatorCoordinator())
//}
