//
//  OnBoarding.swift
//  RecipeAppUI
//
//  Created by Elyura on 09.03.26.
//

import SwiftUI

struct OnBoarding: View {
    @Environment(NavigatorCoordinator.self) var coordinator
    
    var body: some View {
        VStack(spacing:16){
            Image(.onboarding)
                .resizable()
                .scaledToFit()
                
            Text("Start Cooking")
                .font(.h1)
                .foregroundStyle(.appMainText)
                .padding(.top,32)
            
            Text("Let’s join our community\n   to cook better food!")
                .font(.p1)
                .foregroundStyle(.appSecondaryText)
                
            Spacer()
            AppButton(title: "Get Started", variant: .primaryFilled, size: .regular,){
                coordinator.push(.signIn)
            }
            
                .padding(24)
            }
            Spacer()

        }
    }


#Preview {
    NavigationStack{
        OnBoarding()
            .environment(NavigatorCoordinator())
    }
}
