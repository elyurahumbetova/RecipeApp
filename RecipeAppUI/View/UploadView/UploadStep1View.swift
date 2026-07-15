//
//  UploadStep1View.swift
//  RecipeAppUI
//
//  Created by Elyura on 03.07.26.
//

import SwiftUI
import PhotosUI

struct UploadStep1View: View {
    @Bindable var viewModel: UploadViewModel
    @State private var localization = LocalizedManager.shared
    @FocusState private var isDescritionFocused: Bool


    var body: some View {
        VStack {
            PhotosPicker(selection: $viewModel.coverPhotoItem, matching: .images) {
                Color.clear
                    .aspectRatio(2/1, contentMode: .fit)
                    .overlay(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.appOutline, style: StrokeStyle(lineWidth: 2))
                            if let coverImage = viewModel.coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                VStack {
                                    Image("CoverImage")
                                        .padding(.bottom, 21)
                                    Text(localization.t("Add cover photo"))
                                        .font(.h3)
                                        .foregroundStyle(.appMainText)
                                        .padding(.bottom, 8)
                                    Text(localization.t("(up to 120 Mb)"))
                                        .font(.s)
                                        .foregroundStyle(.appSecondaryText)
                                        .padding(.bottom, 16)
                                }
                            }
                        }
                        .onChange(of: viewModel.coverPhotoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    viewModel.coverImage = uiImage
                                }
                            }
                        }
                    )
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)

        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading,spacing: 10){
                Text(localization.t("Is it food or drink?"))
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                Picker("",selection:$viewModel.foodType){
                    ForEach(FoodType.allCases, id:\.self){ type in
                        Text(localization.t(type.title))
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onAppear {
                    UISegmentedControl.appearance().setTitleTextAttributes(
                        [.foregroundColor: UIColor.appPrimary],
                        for: .selected
                    )
                }
            }
            VStack(alignment:.leading,spacing: 10){
                
                Text(localization.t("Food/Drink"))
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                AppTextField(type: .other(placeholder: localization.t("Enter food/drink name"), leadingIcon: nil), text: $viewModel.foodName)
                    .onChange(of: viewModel.foodName){ _,_ in
                        if viewModel.foodNameError != nil {
                            viewModel.validationStep1()
                        }
                        
                    }
                if let error = viewModel.foodNameError{
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.s)
                }
            }
            VStack(alignment:.leading,spacing: 10){
                
                Text(localization.t("Description"))
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                    .padding(.top,14)
                TextField(localization.t("Tell a little about your food/drink"), text: $viewModel.descriptionText, axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .focused($isDescritionFocused)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isDescritionFocused ? .appPrimary : .appOutline
                                , lineWidth: 1)
                    )
                    .onChange(of: viewModel.descriptionText){ _, _ in
                        
                        if viewModel.descriptionError != nil {
                            viewModel.validationStep1()
                        }
                    }
                if let error = viewModel.descriptionError{
                    Text(error)
                        .font(.s)
                        .foregroundStyle(.red)
                }

                
            }
            
            
            

            
                
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

