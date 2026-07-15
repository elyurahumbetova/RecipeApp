import SwiftUI
import FirebaseFirestore
import Kingfisher

struct HomeContentView: View {
    @State private var text = ""
    @State private var selectedCategory = "All"
    @State private var viewModel = HomeViewModel()

    @State private var headerHeight: CGFloat = 0
    @State private var headerOffset: CGFloat = 0

    @State private var localization = LocalizedManager.shared
    @Environment(NavigatorCoordinator.self) private var coordinator

    private let categories = [
        "All",
        "Food",
        "Drink"
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var filteredRecipes: [RecipeModel] {
        var result = viewModel.recipes

        if selectedCategory != "All" {
            result = result.filter { recipe in
                recipe.type.rawValue.caseInsensitiveCompare(
                    selectedCategory
                ) == .orderedSame
            }
        }

        if !text.isEmpty {
            result = result.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(text)
            }
        }

        return result
    }

    var body: some View {
        GeometryReader { containerProxy in
            ZStack(alignment: .top) {
                homeScrollView(
                    availableHeight: containerProxy.size.height
                )

                collapsibleHeader
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newHeight in
                        updateHeaderHeight(newHeight)
                    }
                    .offset(y: headerOffset)
                    .zIndex(10)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .clipped()
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadData()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .recipeUploaded
            )
        ) { _ in
            Task {
                await viewModel.refreshRecipe()
            }
        }
    }


    private func homeScrollView(availableHeight: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: headerHeight)

                recipeContent
                    .frame(maxWidth: .infinity)
                    .frame(
                        minHeight: availableHeight,
                        alignment: .top
                    )

                Spacer()
                    .frame(height: 80)
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

    private var collapsibleHeader: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                SearchField(text: $text)

                Text(localization.t("Category"))
                    .font(.h2)
                    .foregroundStyle(.appMainText)

                HStack(spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        AppButton(
                            title: localization.t(category),
                            variant: selectedCategory == category
                                ? .primaryFilled
                                : .secondaryTextFilled,
                            size: .small
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(24)

            Rectangle()
                .fill(.appForm)
                .frame(height: 5)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }


    private func updateHeaderHeight(_ newHeight: CGFloat) {
        guard newHeight > 0 else {
            return
        }

        guard abs(headerHeight - newHeight) > 0.5 else {
            return
        }

        headerHeight = newHeight
        headerOffset = min(
            0,
            max(
                -newHeight,
                headerOffset
            )
        )
    }

    private func updateHeaderOffset(
        oldScrollOffset: CGFloat,
        newScrollOffset: CGFloat
    ) {
        guard headerHeight > 0 else {
            return
        }

    
        if newScrollOffset <= 0 {
            headerOffset = 0
            return
        }

        let scrollDelta =
            newScrollOffset - oldScrollOffset

        guard abs(scrollDelta) > 0.1 else {
            return
        }

        let newHeaderOffset =
            headerOffset - scrollDelta

        headerOffset = min(
            0,
            max(
                -headerHeight,
                newHeaderOffset
            )
        )
    }

    @ViewBuilder
    private var recipeContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 50)

        } else if filteredRecipes.isEmpty {
            Text(localization.t("No recipe found"))
                .foregroundStyle(.appSecondaryText)
                .frame(maxWidth: .infinity)
                .padding(.top, 50)

        } else {
            LazyVGrid(
                columns: columns,
                spacing: 16
            ) {
                ForEach(filteredRecipes) { recipe in
                    recipeItem(recipe)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    private func recipeItem(_ recipe: RecipeModel) -> some View {
        let user = viewModel.profiles[recipe.userId ?? ""]

        return VStack(
            alignment: .leading,
            spacing: 8
        ) {
            HStack(spacing: 8) {
                KFImage(
                    URL(
                        string: user?.profileImage ?? ""
                    )
                )
                .placeholder {
                    Color.gray.opacity(0.3)
                }
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                Text(
                    user?.userName
                        ?? localization.t("Unknown")
                )
                .font(.p2)
                .foregroundStyle(.appMainText)
                .lineLimit(1)
            }

            RecipeCardView(recipe: recipe)
                .clipped()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            coordinator.push(
                .detailView1(recipe)
            )
        }
    }
}
