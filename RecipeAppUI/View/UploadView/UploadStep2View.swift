//
//  StepVeiw2.swift
//  RecipeAppUI
//
//  Created by Elyura on 26.03.26.
//



import Lottie
import SwiftUI

struct UploadStep2View: View {
    @Bindable var viewModel: UploadViewModel
    @FocusState private var ingredientFocus: Int?
    @FocusState private var stepFocus: Int?
    @State private var localization = LocalizedManager.shared

    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading,spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(localization.t("Cooking Durantion"))
                            .font(.h2)
                            .foregroundStyle(.appMainText)
//                            .padding(.top,14)
                        Text(localization.t("(in minutes)"))
                            .font(.p1)
                            .foregroundStyle(.appSecondaryText)
                    }
                    HStack {
                        Text("<10")
                            .font(.h3)
                            .foregroundStyle(.appPrimary)
                        Spacer()
                        Text("\(Int(viewModel.cookingDuration))")
                            .font(.h3)
                            .foregroundStyle(viewModel.cookingDuration < 35 ? .appSecondaryText : .appPrimary)
                        Spacer()
                        Text(">60")
                            .font(.h3)
                            .foregroundStyle(viewModel.cookingDuration > 59 ? .appPrimary : .appSecondaryText)
                    }
                    Slider(value: $viewModel.cookingDuration, in: 10...60, step: 1.0)
                        .tint(.appPrimary)
                    
                    Rectangle()
                        .fill(.appForm)
                        .frame(height: 8)
                    Text(localization.t("Ingredients"))
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                        .padding(.top,16)

                    ForEach($viewModel.ingredients.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            Image("Drag")
                                .foregroundStyle(.appSecondaryText)
                                .frame(width: 28, height: 28)
                                .onDrag {
                                    NSItemProvider(object: "\(index)" as NSString)
                                }
                            
                            AppTextField(
                                type: .other(placeholder: localization.t("Enter ingredient"), leadingIcon: nil),
                                text: $viewModel.ingredients[index]
                            )
                            .focused($ingredientFocus,equals: index)
                            .submitLabel(.next)
                            .onSubmit{
                                let target  = viewModel.nextIngredientFocus(after: index)
                                
                                DispatchQueue.main.async{
                                    ingredientFocus = target
                                }
                            }
                            
                            Button {
                                viewModel.removeIngredient(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                                    .frame(width: 28, height: 28)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))

                    }
                }
                AppButton(title: localization.t("+ Ingrediet"), variant: .secondaryTextOutlined, size: .regular) {
                    let newIndex = viewModel.addIngredient()
                    DispatchQueue.main.async{
                        
                        ingredientFocus = newIndex
                    }
                }
                .padding(.top, 16)
                
                Rectangle()
                    .fill(.appForm)
                    .frame(height: 8)
                
                VStack(alignment: .leading) {
                    Text(localization.t("Steps"))
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                        .padding(.top,16)

                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.steps.indices, id: \.self) { index in
                            HStack(alignment: .center, spacing: 4) {
                                Text("\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(.appMainText)
                                    .clipShape(Circle())
                                
                                AppTextField(
                                    type: .other(placeholder: "Step \(index + 1)", leadingIcon: nil),
                                    text: $viewModel.steps[index],
                                    axis: .vertical
                                )
                                .lineLimit(1...4)
                                .focused($stepFocus,equals: index)
                                .submitLabel(.next)
                                .onSubmit {
                                    let target = viewModel.nextStepFocus(after: index)
                                    DispatchQueue.main.async{
                                        stepFocus = target
                                    }
                                }
                                
                                if viewModel.steps.count > 1 {
                                    Button {
                                        viewModel.removeStep(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity.combined(with: .scale(scale: 0.9))
                            ))

                        }
                        
                        Button {
                            let newIndex = viewModel.addSteps()
                            DispatchQueue.main.async{
                                
                                stepFocus = newIndex
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(localization.t("Add Step"))
                            }
                            .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.4))
                        }
                    }
                    
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}
