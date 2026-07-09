//
//  SuccessSheet.swift
//  RecipeAppUI
//
//  Created by Elyura on 03.07.26.
//

import SwiftUI
import Lottie

struct SuccessSheetView: View {
    var onDone: () -> Void
    @State private var localization = LocalizedManager.shared


    var body: some View {
        VStack {
            LottieView(animation: .named("success"))
                .playing()
                .frame(width: 200, height: 200)
            Text(localization.t("Upload Success"))
                .foregroundStyle(.appMainText)
                .font(.h1)
            Text(localization.t("Your recipe has been uploaded, you can see it on your profile"))
                .foregroundStyle(.appSecondaryText)
                .font(.p2)
                .multilineTextAlignment(.center)
            AppButton(title: localization.t("Back to Home"), variant: .primaryFilled, size: .regular) {
                onDone()
            }
            .padding(.top,24)
        }
        .padding(.horizontal, 24)

    }
}
//#Preview {
//    SuccessSheetView()
//}
