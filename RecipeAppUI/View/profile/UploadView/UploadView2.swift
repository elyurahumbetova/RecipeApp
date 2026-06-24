//
//  StepVeiw2.swift
//  RecipeAppUI
//
//  Created by Elyura on 26.03.26.
//

import SwiftUI
import Lottie
import Supabase
import FirebaseFirestore
import FirebaseAuth

struct UploadView2: View {
    
    var foodName: String
    var descriptionText: String
    var cookingDuration: Int
    var coverImage: UIImage?
    @Environment(NavigatorCoordinator.self) var coordinator
    @State private var currentStep = 2
    @State private var viewModel = UploadViewModel()
    var body: some View {
        VStack{
            HStack{
                Button("Cancel"){
                    coordinator.pop()
                }
                    .foregroundStyle(.appSecondary)
                    .font(.h2)
                Spacer()
                Text("\(currentStep)/")
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                Text("2")
                    .font(.h2)
                    .foregroundStyle(.appSecondaryText)
            }
            .padding(.bottom,34)
            ScrollView{
                VStack(alignment: .leading){
                    Text("Ingredients")
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                    ForEach($viewModel.ingredients.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            Image("Drag")
                                .foregroundStyle(.appSecondaryText)
                                .frame(width: 28, height: 28)
                                .onDrag {
                                    NSItemProvider(object: "\(index)" as NSString)
                                }
                            
                            AppTextField(
                                type: .other(placeholder: "Enter ingredient", leadingIcon: nil),
                                text: $viewModel.ingredients[index]
                            )
                            
                            Button {
                                if viewModel.ingredients.count > 1 {
                                    viewModel.ingredients.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                                    .frame(width: 28, height: 28)
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                }
                AppButton(title: " + Ingrediet", variant: .secondaryTextOutlined, size: .regular){
                    viewModel.ingredients.append("")
                }
                    .padding(.top,16)
            }
        }
        .padding(24)
        Rectangle()
            .fill(.appForm)
            .frame(height: 8)
        ScrollView{
            VStack(alignment: .leading){
                Text("Steps")
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                
                
                VStack(alignment: .leading,spacing: 8) {
                    ForEach(viewModel.steps.indices, id: \.self) { index in
                        HStack(alignment: .center, spacing: 4) {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(.appMainText)
                                .clipShape(Circle())
                            
                            AppTextField(
                                type: .other(placeholder: "Step \(index + 1)", leadingIcon: nil), text:$viewModel.steps[index],axis: .vertical)
                                .lineLimit(1...4)
                               
                            
                            if viewModel.steps.count > 1 {
                                Button {
                                    viewModel.steps.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button {
                        viewModel.steps.append("")
                    } label: {
                        HStack{
                            Image(systemName: "plus.circle.fill")
                            Text("Add Step")
                        }
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.4))
                    }
                }
            }
        }
        .padding(.horizontal,24)
        
        Spacer()
        
        HStack(spacing: 15){
            AppButton(title: "Back", variant: .secondaryTextFilled, size: .small){
                coordinator.pop()
            }
            AppButton(title: "Next", variant: .primaryFilled, size: .small){
               
                Task{
                    await viewModel.uploadRecipe(
                        foodName: foodName,
                        descriptionText: descriptionText,
                        cookingDuration: cookingDuration,
                        coverImage: coverImage)
                }
                }
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $viewModel.showSuccess){
            VStack{
                LottieView(animation: .named("success"))
                    .playing()
                    .frame(width: 200, height: 200)
                Text("Upload Success")
                    .foregroundStyle(.appMainText)
                    .font(.h1)
                Text("Your recipe has been uploaded,you can see it on your profile")
                    .foregroundStyle(.appSecondaryText)
                    .font(.p2)
                    .multilineTextAlignment(.center)
                AppButton(title: "Back", variant: .primaryFilled, size: .regular, ){
                    
                    coordinator.setRoot(.home)
                    viewModel.showSuccess = false
                }
                
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(24)
        }

    }
    
        
}

#Preview {
    UploadView2(
        foodName: "TEst", descriptionText: "hello", cookingDuration: 30
    )
        .environment(NavigatorCoordinator())
}
