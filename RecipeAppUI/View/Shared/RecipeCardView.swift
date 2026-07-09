import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

struct RecipeCardView: View {
    let recipe: RecipeModel
    @State private var isLiked = false
    @State private var localization = LocalizedManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            ZStack(alignment: .topTrailing) {

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 200)
                    .overlay {
                        if let imageURL = recipe.imageURL,
                           let url = URL(string: imageURL) {

                            KFImage(url)
                                .placeholder {
                                    placeholderView
                                }
                                .resizable()
                                .scaledToFill()
                        } else {
                            placeholderView
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Button {
                    Task {
                        await toggleLike(recipe: recipe)
                    }
                } label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(8)
            }

            Text(recipe.title)
                .font(.h2)
                .foregroundStyle(.appMainText)
                .lineLimit(1)

            HStack(spacing: 4) {
                Text(localization.t("Food"))
                    .font(.p2)
                    .foregroundStyle(.appSecondaryText)

                Circle()
                    .fill(.appSecondaryText)
                    .frame(width: 4, height: 4)

                Text(String(format: localization.t("%lld mins"),recipe.cookingMinute))
                    .font(.p2)
                    .foregroundStyle(.appSecondaryText)
            }
        }
        .onAppear {
            Task {
                await checkIfLiked()
            }
        }
    }

    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.15)

            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
        }
    }

    func checkIfLiked() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let doc = try? await Firestore.firestore()
            .collection("liked")
            .document(uid)
            .getDocument()

        let ids = doc?.data()?["recipes"] as? [String] ?? []

        await MainActor.run {
            isLiked = ids.contains(recipe.id ?? "")
        }
    }

    func toggleLike(recipe: RecipeModel) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let recipeId = recipe.id else { return }

        let docRef = Firestore.firestore()
            .collection("liked")
            .document(uid)

        if isLiked {
            try? await docRef.updateData([
                "recipes": FieldValue.arrayRemove([recipeId])
            ])

            await MainActor.run {
                isLiked = false
            }

        } else {
            try? await docRef.setData([
                "recipes": FieldValue.arrayUnion([recipeId])
            ], merge: true)

            await MainActor.run {
                isLiked = true
            }
        }
    }
}
