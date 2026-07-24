import SwiftUI
import PhotosUI
import Kingfisher
import FirebaseAuth

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
    private let tabs = ["Recipes", "Liked"]
    @State private var localization = LocalizedManager.shared

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = index
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text(localization.t(tabs[index]))
                            .font(.h3)
                            .foregroundColor(
                                selected == index
                                    ? .appPrimary
                                    : .appSecondaryText
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)

                        Rectangle()
                            .fill(
                                selected == index
                                    ? .appPrimary
                                    : Color.clear
                            )
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
        }
    }
}

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()

    @State private var selectedTab = 0
    @State private var selectedItem: PhotosPickerItem?

    @State private var profileHeaderHeight: CGFloat = 190
    @State private var profileHeaderOffset: CGFloat = 0

    @State private var localization = LocalizedManager.shared

    @Environment(NavigatorCoordinator.self) private var coordinator

    @Environment(UserStore.self) private var userStore

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            GeometryReader { containerProxy in
                ZStack(alignment: .top) {
                    profileScrollView(
                        availableHeight: containerProxy.size.height
                    )

                    profileHeader
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { newHeight in
                            guard newHeight > 0 else {
                                return
                            }

                            profileHeaderHeight = newHeight

                            profileHeaderOffset = min(
                                0,
                                max(
                                    -newHeight,
                                    profileHeaderOffset
                                )
                            )
                        }
                        .offset(y: profileHeaderOffset)
                        .zIndex(10)
                    
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .clipped()
            }
            .navigationTitle(localization.t("My Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {
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
            
                
                guard
                    let uid = Auth.auth().currentUser?.uid,
                    let profile = viewModel.profile
                
                else {
                    return
                }

                userStore.setProfile(id: uid,profile: profile)
                
            }
            .onChange(of: selectedTab) { _, newTab in
                guard newTab == 1 else {
                    return
                }

                Task {
                    await viewModel.fetchLikedRecipes()
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .recipeUploaded
                )
            ) { _ in
                Task {
                    await viewModel.fetchMyRecipes()
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .recipeLikedChange
                )
                
            ){notification in
                guard let change = notification.object as? RecipeLikedChange else { return }
                withAnimation(.easeInOut(duration: 0.24)){
                    viewModel.applyLikeChange(change)
                }
                
            }
           
        }
    }

    private func profileScrollView(
        availableHeight: CGFloat
    ) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: profileHeaderHeight)

                ProfileTabPicker(selected: $selectedTab)
                    .padding(.top, 12)
                    .background(Color(.systemBackground))

                profileContent
                    .frame(maxWidth: .infinity)
                    .frame(
                        minHeight: max(
                            200,
                            availableHeight - 60
                        ),
                        alignment: .top
                    )
            }
        }
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            max(
                0,
                geometry.contentOffset.y
                    + geometry.contentInsets.top
            )
        } action: { oldOffset, newOffset in
            updateHeaderOffset(
                oldScrollOffset: oldOffset,
                newScrollOffset: newOffset
            )
        }
    }

    private func updateHeaderOffset(
        oldScrollOffset: CGFloat,
        newScrollOffset: CGFloat
    ) {
        guard profileHeaderHeight > 0 else {
            return
        }

      
        if newScrollOffset <= 0 {
            profileHeaderOffset = 0
            return
        }

        let scrollDelta =
            newScrollOffset - oldScrollOffset

        guard abs(scrollDelta) > 0.1 else {
            return
        }

    
        let newHeaderOffset =
            profileHeaderOffset - scrollDelta

        profileHeaderOffset = min(
            0,
            max(
                -profileHeaderHeight,
                newHeaderOffset
            )
        )
    }


    private var profileHeader: some View {
        VStack(spacing: 8) {
            profilePhoto

            Text(
                viewModel.userName.isEmpty
                    ? localization.t("Loading...")
                    : viewModel.userName
            )
            .font(.h2)
            .foregroundColor(.appMainText)
            .lineLimit(1)

            profileStats
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    private var profilePhoto: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            ZStack {
                Circle()
                    .fill(.appForm)
                
                profilePhotoContent
            }
            .clipShape(Circle())
        }
        .frame(width: 90, height: 90)
        .shadow(
            color: .black.opacity(0.12),
            radius: 8,
            x: 0,
            y: 4
        )
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let image = await viewModel.loadSelectedImage(newItem) else {
                    return
                }
                
                guard let url = await viewModel.uploadProfileImage(image)else{
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else{
                    return
                }

                userStore.updateProfile(id: uid) { profile in
                     UserModel(
                        userName: profile.userName,
                        profileImage: url
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var profilePhotoContent: some View {
        if let image = viewModel.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()

        } else if !viewModel.profileImageURL.isEmpty {
            KFImage(
                URL(string: viewModel.profileImageURL)
            )
            .placeholder {
                ProgressView()
            }
            .resizable()
            .scaledToFill()

        } else {
            Image(
                systemName: "person.crop.circle.fill"
            )
            .resizable()
            .scaledToFit()
            .foregroundColor(.appSecondaryText)
        }
    }


    private var profileStats: some View {
        HStack(spacing: 0) {
            StatItem(
                value: viewModel.recipes.count,
                label: localization.t("Recipes")
            )

            statDivider

            StatItem(
                value: 782,
                label: localization.t("Following")
            )

            statDivider

            StatItem(
                value: 1287,
                label: localization.t("Followers")
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color(.systemGray4))
            .frame(width: 1, height: 36)
    }


    @ViewBuilder
    private var profileContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(
                    maxWidth: .infinity,
                    minHeight: 200
                )

        } else if selectedTab == 0 {
            recipeGrid(
                recipes: viewModel.recipes,
                emptyText: localization.t(
                    "No recipes yet"
                ),
                canDelete: true
                
            )

        } else {
            recipeGrid(
                recipes: viewModel.likedRecipes,
                emptyText: localization.t(
                    "No liked recipes yet"
                ),
                canDelete: false
            )
        }
    }
    @ViewBuilder
    private func recipeGrid(
        recipes: [RecipeModel],
        emptyText: String,
        canDelete: Bool
    ) -> some View {
        if recipes.isEmpty {
            VStack {
                Text(emptyText)
                    .foregroundStyle(.appSecondaryText)
                    .padding(.top, 40)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)

        } else {
            LazyVGrid(
                columns: columns,
                spacing: 16
            ) {
                ForEach(recipes) { recipe in
                  recipeGridItem(
                    recipe,canDelete: canDelete
                  )
                }
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private func recipeGridItem(_ recipe: RecipeModel,canDelete: Bool) -> some View{
        if canDelete{
            RecipeCardView(recipe: recipe)
                .contentShape(Rectangle())
                .onTapGesture {
                    coordinator.push(
                        .detailView1(recipe)
                    )
                }
                .contextMenu {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteRecipe(
                                recipe
                            )
                        }
                    } label: {
                        Label(
                            localization.t("Delete"),
                            systemImage: "trash"
                        )
                    }
                }
        }else{
            RecipeCardView(recipe: recipe)
                .contentShape(Rectangle())
                .onTapGesture {
                    coordinator.push(
                        .detailView1(recipe)
                    )
                }
        }
    }
}


// #Preview {
//     ProfileView()
//         .environment(NavigatorCoordinator())
// }
