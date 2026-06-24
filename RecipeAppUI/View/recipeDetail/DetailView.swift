//
//  DetailView1.swift
//  RecipeAppUI
//
//  Created by Elyura on 20.06.26.
//

//
//  DetailView1.swift
//  RecipeAppUI
//
//  Created by Elyura on 20.06.26.
//

import SwiftUI
import FirebaseFirestore


import SwiftUI
import FirebaseFirestore

struct DetailView1: View {
    let recipe: RecipeModel
    
    @State private var dragOffset: CGFloat = .zero
    @State private var isExpanded: Bool = false
    @State private var user: UserModel?
    
    var body: some View {
        GeometryReader { geometry in
            let imageHeight = geometry.size.height / 2.5
            let collapsedOffset: CGFloat = imageHeight - 30
            let expandedOffset: CGFloat = 60
            
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: recipe.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: geometry.size.width, height: imageHeight)
                .clipped()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Spacer()
                        Capsule()
                            .fill(.appForm)
                            .frame(width: 40, height: 5)
                            .padding(.top, 12)
                        Spacer()
                    }
                    
                    Text(recipe.title)
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Food    \(recipe.cookingMinute) mins")
                        .font(.p2)
                        .foregroundStyle(.appSecondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        AsyncImage(url: URL(string: user?.profileImage ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        Text(user?.userName ?? "Unknown")
                            .font(.h3)
                            .foregroundStyle(.appMainText)
                    }
                    .padding(.top, 16)
                    
                    Divider().padding(.bottom, 16)
                    
                    Text("Description")
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                        .padding(.bottom, 8)
                    Text(recipe.description)
                        .font(.p2)
                        .foregroundStyle(.appSecondaryText)
                    
                    Divider().padding(.bottom, 16)
                    
                    Text("Ingredients")
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.appPrimary)
                                    .frame(width: 28, height: 28)
                                    .background(Color.green.opacity(0.15))
                                    .clipShape(Circle())
                                Text(ingredient)
                                    .font(.p2)
                                    .foregroundStyle(.appMainText)
                            }
                        }
                    }
                    
                    Divider().padding(.bottom, 16)
                    
                    Text("Steps")
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.p2)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(.appMainText)
                                    .clipShape(Circle())
                                
                                Text(step)
                                    .font(.p2)
                                    .foregroundColor(.appMainText)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .offset(y: (isExpanded ? expandedOffset : collapsedOffset) + dragOffset)
                .animation(.interactiveSpring(), value: dragOffset)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if isExpanded {
                                    if value.translation.height > 50 {
                                        isExpanded = false
                                    }
                                } else {
                                    if value.translation.height < -50 {
                                        isExpanded = true
                                    }
                                }
                                dragOffset = .zero
                            }
                        }
                )
                
                
            }
        }
        .ignoresSafeArea(edges: .top)
        .task{
            await fetchUser()
        }
    }
    func fetchUser() async {
           guard let userId = recipe.userId else { return }
           do {
               let doc = try await Firestore.firestore()
                   .collection("profile")
                   .document(userId)
                   .getDocument()
               self.user = try doc.data(as: UserModel.self)
           } catch {
               print("🔴 user fetch error:", error)
           }
       }
}

//
//#Preview {
//    DetailView1(recipe: RecipeModel(
//        id: "nkancdla",
//        title: "milk",
//        description: "delicious",
//        cookingMinute: 23,
//        imageURL: nil,
//        ingredients: ["dkamsl", "masdskml"],
//        steps: ["nalkcnlas"],
//        createdAt: Timestamp(date: Date()),
//        userId: nil
//        
//    ),
//    user: UserModel(userName: "Emily", profileImage: "https://olo-images-live.imgix.net/cb/cbe0798e0b9e4bbbb7391c96da4d9010.jpg")
//    )
//}

