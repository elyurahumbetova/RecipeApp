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
import Kingfisher

struct DetailView1: View {
    let recipe: RecipeModel
    @State private var localization = LocalizedManager.shared

   
    @State private var dragOffset: CGFloat = .zero
    @State private var isExpanded: Bool = false
    @State private var viewModel = DetailViewModel()
    private var cookingText: String {
        localization.t("Food {count} mins")
            .replacingOccurrences(of: "{count}", with: "\(recipe.cookingMinute)")
    }
    var body: some View {
        GeometryReader { geometry in
            let imageHeight = geometry.size.height / 2.5
            let collapsedOffset: CGFloat = imageHeight - 30
            let expandedOffset = max(
                100, geometry.safeAreaInsets.top + 70
            )
            
            let baseOffset = isExpanded ? expandedOffset : collapsedOffset
            let currentSheetOffset = min(
                collapsedOffset,
                max(expandedOffset, baseOffset + dragOffset)
                
            )
            ZStack(alignment: .top) {
                
                recipeCoverImage(
                    width: geometry.size.width,
                    height: imageHeight
                )
                
                detailSheet(expandedOffset: expandedOffset,collapsedOffset: collapsedOffset)
                    .frame(
                        width: geometry.size.width,
                        height: max(200,geometry.size.height - currentSheetOffset),
                        alignment: .top)
                    .offset(y: currentSheetOffset)
                    .zIndex(10)
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
            .background(Color(uiColor:.systemBackground))
        }
        .ignoresSafeArea(edges: [.top,.bottom])
        .navigationBarBackButtonHidden(false)
        .task{
            guard let userId = recipe.userId else{ return }
            await viewModel.fetchUser(userId: userId)
        }
    }
    
    
    
    private func recipeCoverImage(
        width: CGFloat, height: CGFloat
    ) -> some View{
        KFImage(URL(string: recipe.imageURL ?? ""))
            .placeholder{
                Color.gray.opacity(0.3)
            }
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
    }
    
    private func detailSheet(
           expandedOffset: CGFloat,
           collapsedOffset: CGFloat
       ) -> some View {
           VStack(spacing: 0) {
               dragHandle(
                   expandedOffset: expandedOffset,
                   collapsedOffset: collapsedOffset
               )

               ScrollView {
                   VStack(
                       alignment: .leading,
                       spacing: 12
                   ) {
                       headerSection

                       sectionDivider

                       descriptionSection

                       sectionDivider

                       ingredientsSection

                       sectionDivider

                       stepsSection
                   }
                   .padding(.horizontal, 24)
                   .padding(.bottom, 50)
                   .frame(
                       maxWidth: .infinity,
                       alignment: .leading
                   )
               }
               .scrollIndicators(.hidden)
               .scrollBounceBehavior(.basedOnSize)
           }
           .background(
               Color(uiColor: .systemBackground)
           )
           .clipShape(
               UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28,
                style: .continuous
               )
           )
           .shadow(
               color: .black.opacity(0.1),
               radius: 12,
               y: -4
           )
       }
    private func dragHandle(
        expandedOffset: CGFloat,
        collapsedOffset: CGFloat
    ) -> some View {
        VStack {
            Capsule()
                .fill(Color(uiColor: .tertiaryLabel))
                .frame(width: 40, height: 5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .contentShape(Rectangle())
        .gesture(
            sheetDragGesture(
                expandedOffset: expandedOffset,
                collapsedOffset: collapsedOffset
            )
        )
    }

    private func sheetDragGesture(
        expandedOffset: CGFloat,
        collapsedOffset: CGFloat
    ) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let baseOffset = isExpanded
                    ? expandedOffset
                    : collapsedOffset

                let proposedOffset =
                    baseOffset + value.translation.height

                let clampedOffset = min(
                    collapsedOffset,
                    max(
                        expandedOffset,
                        proposedOffset
                    )
                )

                dragOffset =
                    clampedOffset - baseOffset
            }
            .onEnded { value in
                let baseOffset = isExpanded
                    ? expandedOffset
                    : collapsedOffset

                let predictedOffset =
                    baseOffset
                    + value.predictedEndTranslation.height

                let middleOffset =
                    (expandedOffset + collapsedOffset) / 2

                withAnimation(
                    .spring(
                        response: 0.4,
                        dampingFraction: 0.82
                    )
                ) {
                    isExpanded =
                        predictedOffset < middleOffset

                    dragOffset = .zero
                }
            }
    }


    private var headerSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text(recipe.title)
                .font(.h2)
                .foregroundStyle(.appMainText)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Text(cookingText)
                .font(.p2)
                .foregroundStyle(.appSecondaryText)

            userSection
                .padding(.top, 16)
        }
    }

    private var userSection: some View {
        HStack(spacing: 10) {
            KFImage(
                URL(
                    string: viewModel.user?.profileImage ?? ""
                )
            )
            .placeholder {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            Text(
                viewModel.user?.userName
                    ?? localization.t("Unknown")
            )
            .font(.h3)
            .foregroundStyle(.appMainText)
        }
    }


    private var descriptionSection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text(localization.t("Description"))
                .font(.h2)
                .foregroundStyle(.appMainText)

            Text(recipe.description)
                .font(.p2)
                .foregroundStyle(.appSecondaryText)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }


    private var ingredientsSection: some View {
        VStack(
            alignment: .leading,
            spacing: 15
        ) {
            Text(localization.t("Ingredients"))
                .font(.h2)
                .foregroundStyle(.appMainText)

            ForEach(
                recipe.ingredients,
                id: \.self
            ) { ingredient in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(
                            .system(
                                size: 12,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.appPrimary)
                        .frame(width: 28, height: 28)
                        .background(
                            .appPrimary.opacity(0.15)
                        )
                        .clipShape(Circle())

                    Text(ingredient)
                        .font(.p2)
                        .foregroundStyle(.appMainText)
                }
            }
        }
    }


    private var stepsSection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text(localization.t("Steps"))
                .font(.h2)
                .foregroundStyle(.appMainText)

            ForEach(
                Array(recipe.steps.enumerated()),
                id: \.offset
            ) { index, step in
                HStack(
                    alignment: .top,
                    spacing: 12
                ) {
                    Text("\(index + 1)")
                        .font(.p2)
                        .foregroundStyle(
                            Color(uiColor: .systemBackground)
                        )
                        .frame(width: 28, height: 28)
                        .background(
                            Color(uiColor: .label)
                        )
                        .clipShape(Circle())

                    Text(step)
                        .font(.p2)
                        .foregroundStyle(.appMainText)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            }
        }
    }

    private var sectionDivider: some View {
        Divider()
            .padding(.bottom, 16)
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

