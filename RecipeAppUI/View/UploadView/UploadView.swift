
//
//  UploadView.swift
//  RecipeAppUI
//
//  Created by Elyura on 26.03.26.
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @Environment(NavigatorCoordinator.self) var coordinator
    @State private var currentStep : Int = 1
    @State private var coverPhotoItem: PhotosPickerItem? = nil
    @State private var coverImage: UIImage? = nil
    @State private var foodName: String = ""
    @State private var desciptionText: String = ""
    @State private var cookingDuration: Double = 35
    @State private var showAlert = false
    

    var body: some View {
        VStack{
            HStack{
                Button("Cancel"){
                    coordinator.pop()
                }
                    .foregroundStyle(.appSecondary)
                    .font(.h2)
                Spacer()
                Text("\(currentStep) /")
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                 Text("2")
                    .font(.h2)
                    .foregroundStyle(.appSecondaryText)
            }
            .padding(.bottom,34)
            VStack{
                PhotosPicker(selection: $coverPhotoItem,matching: .images) {
                    
                    
                    Color.clear
                        .aspectRatio(2/1,contentMode: .fit)
                        .overlay(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.appOutline, style: StrokeStyle(lineWidth: 2))
                                if let coverImage {
                                    Image(uiImage: coverImage)
                                        .resizable()
                                        .scaledToFill()
                                    
                                    
                                }else{
                                    VStack{
                                        Image("CoverImage")
                                            .padding(.bottom,21)
                                        Text("Add cover photo")
                                            .font(.h3)
                                            .foregroundStyle(.appMainText)
                                            .padding(.bottom,8)
                                        Text("(up to 120 Mb)")
                                            .font(.s)
                                            .foregroundStyle(.appSecondaryText)
                                            .padding(.bottom,16)
                                    }
                                }
                            }
                                .onChange(of: coverPhotoItem){_ , newItem in
                                    Task{
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) ,
                                           let uiImage = UIImage(data: data){
                                            coverImage = uiImage
                                        }
                                        
                                    }
                                }
                            )
                          }
                
                    
                }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12 ))
            .padding(.horizontal, 12)
            }
        .padding(.horizontal,24)
            
            VStack(alignment: .leading,spacing: 10){
                Text("Food")
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                AppTextField(type: .other(placeholder: "Enter food name ", leadingIcon: nil), text: $foodName)
                Text("Description")
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                
                TextField("Tell a little about your food", text: $desciptionText,axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.appOutline,lineWidth: 1)
                    )
                HStack(alignment: .firstTextBaseline){
                    Text("Cooking Durantion")
                        .font(.h2)
                        .foregroundStyle(.appMainText)
                    Text("(in minutes)")
                        .font(.p1)
                        .foregroundStyle(.appSecondaryText)
                }
                HStack {
                    Text("<10")
                        .font(.h3)
                        .foregroundStyle(.appPrimary )
                    Spacer()
                    Text("\(Int(cookingDuration))")
                        .font(.h3)
                        .foregroundStyle(cookingDuration < 35 ? .appSecondaryText : .appPrimary )
                    Spacer()
                    Text(">60")
                        .font(.h3)
                        .foregroundStyle(cookingDuration > 59 ? .appPrimary : .appSecondaryText)
                }
                Slider(value: $cookingDuration, in: 10...60,step: 1.0)
                    .tint(.appPrimary)
                AppButton(title: "Next", variant: .primaryFilled, size: .regular){
                    
                    if coverImage == nil {
                        showAlert = true ; return
                    }
                    
                    coordinator.push(.uploadView2(
                    foodName: foodName,
                    description: desciptionText,
                    cookingDuration: Int(cookingDuration),
                    image: coverImage))
                }
                .padding(.top,15)
            }
            .padding(.horizontal,24)
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
            .navigationBarBackButtonHidden(true)
           
            .alert("Image required", isPresented: $showAlert){
                Button("Ok", role: .cancel){}
            }message :{
                Text("Pls upload a recipe image before continuing to next step")
            }
        }
       
        
    }



#Preview {

    UploadView()
        .environment(NavigatorCoordinator())
}
