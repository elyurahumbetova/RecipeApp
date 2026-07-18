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
    private enum ScrollTarget: Hashable {
        case ingredientButton
        case stepButton
        
    }
    
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading,spacing: 16) {
                    cookingDurationSection
                    ingredientsSection(proxy: proxy)
                   
                    divider

                    stepsSection(proxy: proxy)

                    
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }


    private var cookingDurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(localization.t("Cooking Durantion"))
                    .font(.h2)
                    .foregroundStyle(.appMainText)

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
                    .foregroundStyle(
                        viewModel.cookingDuration < 35
                            ? .appSecondaryText
                            : .appPrimary
                    )

                Spacer()

                Text(">60")
                    .font(.h3)
                    .foregroundStyle(
                        viewModel.cookingDuration > 59
                            ? .appPrimary
                            : .appSecondaryText
                    )
            }

            Slider(
                value: $viewModel.cookingDuration,
                in: 10...60,
                step: 1
            )
            .tint(.appPrimary)
            
            
        }
    }

    private func ingredientsSection(proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.t("Ingredients"))
                .font(.h2)
                .foregroundStyle(.appMainText)
                .padding(.top, 16)

            ForEach(viewModel.ingredients.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 12) {
                        Image("Drag")
                            .foregroundStyle(.appSecondaryText)
                            .frame(width: 28, height: 28)
                            .onDrag {
                                NSItemProvider(
                                    object: "\(index)" as NSString
                                )
                            }

                        AppTextField(
                            type: .other(
                                placeholder: localization.t("Enter ingredient"),
                                leadingIcon: nil
                            ),
                            text: $viewModel.ingredients[index]
                        )
                        .focused(
                            $ingredientFocus,
                            equals: index
                        )
                        .submitLabel(.next)
                        .onSubmit {
                            handleIngredientSubmit(
                                at: index,
                                proxy: proxy
                            )
                        }
                        .onChange(
                            of: viewModel.ingredients[index]
                        ) { _, _ in
                            viewModel.ingredientError.remove(index)
                        }

                        Button {
                            viewModel.removeIngredient(at: index)

                            if ingredientFocus == index {
                                ingredientFocus = nil
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.appSecondary)
                                .frame(width: 28, height: 28)
                        }
                    }

                    if viewModel.ingredientError.contains(index) {
                        Text(localization.t("This field is required"))
                            .foregroundStyle(.red)
                            .font(.s)
                            .padding(.leading, 40)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top)
                            .combined(with: .opacity),
                        removal: .opacity
                            .combined(with: .scale(scale: 0.9))
                    )
                )
            }

            AppButton(
                title: localization.t("+ Ingrediet"),
                variant: .secondaryTextOutlined,
                size: .regular
            ) {
                addIngredientAndScroll(proxy: proxy)
            }
                .id(ScrollTarget.ingredientButton)
        }
    }

    private func stepsSection(
        proxy: ScrollViewProxy
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.t("Steps"))
                .font(.h2)
                .foregroundStyle(.appMainText)
                .padding(.top, 16)

            ForEach(viewModel.steps.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 4) {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .foregroundStyle(
                                Color(uiColor: .systemBackground)
                            )
                            .frame(width: 24, height: 24)
                            .background(
                                Color(uiColor: .label)
                            )
                            .clipShape(Circle())

                        AppTextField(
                            type: .other(
                                placeholder: "Step \(index + 1)",
                                leadingIcon: nil
                            ),
                            text: $viewModel.steps[index],
                            axis: .vertical
                        )
                        .lineLimit(1...4)
                        .focused(
                            $stepFocus,
                            equals: index
                        )
                        .submitLabel(.next)
                        .onSubmit {
                            handleStepSubmit(
                                at: index,
                                proxy: proxy
                            )
                        }
                        .onChange(
                            of: viewModel.steps[index]
                        ) { _, _ in
                            viewModel.stepError.remove(index)
                        }

                        if viewModel.steps.count > 1 {
                            Button {
                                viewModel.removeStep(at: index)

                                if stepFocus == index {
                                    stepFocus = nil
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    if viewModel.stepError.contains(index) {
                        Text(localization.t("This field is required"))
                            .font(.s)
                            .foregroundStyle(.red)
                            .padding(.leading, 28)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top)
                            .combined(with: .opacity),
                        removal: .opacity
                            .combined(with: .scale(scale: 0.9))
                    )
                )
            }

            Button {
                addStepAndScroll(proxy: proxy)
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(localization.t("Add Step"))
                }
                .foregroundStyle(.appPrimary)
            }
            .id(ScrollTarget.stepButton)
        }
    }


    private func handleIngredientSubmit(
        at index: Int,
        proxy: ScrollViewProxy
    ) {
        let isLastIngredient =
            index == viewModel.ingredients.indices.last

        if isLastIngredient {
            addIngredientAndScroll(proxy: proxy)
        } else {
            ingredientFocus =
                viewModel.nextIngredientFocus(after: index)
        }
    }
    private func addIngredientAndScroll(
        proxy: ScrollViewProxy
    ) {
        let newIndex = viewModel.addIngredient()

        Task { @MainActor in
            await Task.yield()

            ingredientFocus = newIndex

            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo(
                    ScrollTarget.ingredientButton,
                    anchor: .bottom
                )
            }

            try? await Task.sleep(for: .milliseconds(250))

            withAnimation(.easeInOut(duration: 0.2)) {
                proxy.scrollTo(
                    ScrollTarget.ingredientButton,
                    anchor: .bottom
                )
            }
        }
    }


    private func handleStepSubmit(
        at index: Int,
        proxy: ScrollViewProxy
    ) {
        let isLastStep =
            index == viewModel.steps.indices.last

        if isLastStep {
            addStepAndScroll(proxy: proxy)
        } else {
            stepFocus =
                viewModel.nextStepFocus(after: index)
        }
    }

    private func addStepAndScroll(
        proxy: ScrollViewProxy
    ) {
        let newIndex = viewModel.addSteps()

        Task { @MainActor in
            await Task.yield()

            stepFocus = newIndex

            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo(
                    ScrollTarget.stepButton,
                    anchor: .bottom
                )
            }

            try? await Task.sleep(for: .milliseconds(250))

            withAnimation(.easeInOut(duration: 0.2)) {
                proxy.scrollTo(
                    ScrollTarget.stepButton,
                    anchor: .bottom
                )
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.appOutline.opacity(0.45))
            .frame(height: 8)
            .padding(.horizontal, -24)
    }
}
