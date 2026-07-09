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
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 24)

        VStack(alignment: .leading, spacing: 10) {
            Text(localization.t("Food"))
                .font(.h2)
                .foregroundStyle(.appMainText)
            AppTextField(type: .other(placeholder: localization.t("Enter food name"), leadingIcon: nil), text: $viewModel.foodName)

            Text(localization.t("Description"))
                .font(.h2)
                .foregroundStyle(.appMainText)
                .padding(.top,14)
            TextField(localization.t("Tell a little about your food"), text: $viewModel.descriptionText, axis: .vertical)
                .lineLimit(3...5)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.appOutline, lineWidth: 1)
                )

            HStack(alignment: .firstTextBaseline) {
                Text(localization.t("Cooking Durantion"))
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                    .padding(.top,14)
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
                
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

