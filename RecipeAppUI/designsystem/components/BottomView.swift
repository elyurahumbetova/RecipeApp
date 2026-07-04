//
//  BottomView.swift
//  RecipeAppUI
//
//  Created by Elyura on 04.07.26.
//

import SwiftUI

struct BottomView: View {
    @Bindable var viewModel: UploadViewModel
    var body: some View {
        Group{
            if viewModel.currentStep == 1 {
                AppButton(title: "Next", variant: .primaryFilled, size: .regular) {
                    viewModel.goToStep2()
                }
            }else{
                HStack(spacing: 15) {
                    AppButton(title: "Back", variant: .secondaryTextFilled, size: .small) {
                        viewModel.goToStep1()
                    }
                    AppButton(title: "Next", variant: .primaryFilled, size: .small) {
                        Task {
                            await viewModel.uploadRecipe()
                        }
                    }
                    .disabled(viewModel.isUploading)
                }
            }
        }
        .padding(.horizontal, 24 )
    }
}

//#Preview {
//    BottomView()
//}
