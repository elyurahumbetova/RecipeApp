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
    @State private var ingredients : [String] = ["",""]
    @State private var showSucces: Bool = false
    @State private var steps: String = ""
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
                    ForEach($ingredients.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            Image("Drag")
                                .foregroundStyle(.appSecondaryText)
                                .frame(width: 28, height: 28)
                                .onDrag {
                                    NSItemProvider(object: "\(index)" as NSString)
                                }
                            
                            AppTextField(
                                type: .other(placeholder: "Enter ingredient", leadingIcon: nil),
                                text: $ingredients[index]
                            )
                            
                            Button {
                                if ingredients.count > 1 {
                                    ingredients.remove(at: index)
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
                    ingredients.append("")
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
                
                
                HStack(spacing: 8){
                    Image("List")
                    TextField("Tell a little about your food", text: $steps,axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.appOutline,lineWidth: 1 )
                        )
                }
            }
        }
        .padding(24)
        
        Spacer()
        
        HStack(spacing: 15){
            AppButton(title: "Back", variant: .secondaryTextFilled, size: .small){
                coordinator.pop()
            }
            AppButton(title: "Next", variant: .primaryFilled, size: .small){
               
                uploadRecipe(ingredients: ingredients, steps: [steps])
                
            }
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showSucces){
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
                    showSucces = false
                }
                
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(24)
        }

    }
    func uploadRecipe(ingredients: [String], steps: [String]) {
        let cleanIngredients = ingredients.filter { !$0.isEmpty }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ UID yoxdur")
            return
        }
        
        var data: [String: Any] = [
            "title": foodName,
            "description": descriptionText,
            "cookingMinute": cookingDuration,
            "ingredients": cleanIngredients,
            "steps": steps,
            "createdAt": Timestamp(),
            "userId": uid
        ]
        
       
        
        let db = Firestore.firestore()
        
        let saveToFirestore = {
           
            let recipeRef = db.collection("recipes").document()
            recipeRef.setData(data) { error in
                guard error == nil else {
                    print("❌ Recipe yazma xətası:", error!)
                    return
                }
                print("✅ Recipe yazıldı, ID:", recipeRef.documentID)
                
                
                // 2. Sonra createrecipes/{uid} ə ID-ni əlavə et
                db.collection("createrecipes")
                    .document(uid)
                    .setData(
                        ["recipes": FieldValue.arrayUnion([recipeRef.documentID])],
                        merge: true
                    ) { error in
                        guard error == nil else {
                            print("❌ createrecipes yazma xətası:", error!)
                            return
                        }
                        print("✅ createrecipes yeniləndi")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .recipeUploaded, object: nil)
                            self.showSucces = true
                        }
                    }
            }
        }
        
        if let image = coverImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            let fileName = "\(UUID().uuidString).jpg"
            
            Task {
                do {
                    try await supabase.storage
                        .from("recipes")
                        .upload(fileName, data: imageData)
                    
                    let publicURL = try supabase.storage
                        .from("recipes")
                        .getPublicURL(path: fileName)
                    
                    data["imageURL"] = publicURL.absoluteString
                    saveToFirestore()
                    
                } catch {
                    print("❌ Supabase upload error:", error)
                }
            }
        } else {
            saveToFirestore()  // ← şəkil yoxdursa da işləsin
        }
    }
        
}

#Preview {
    UploadView2(
        foodName: "TEst", descriptionText: "hello", cookingDuration: 30
    )
        .environment(NavigatorCoordinator())
}
