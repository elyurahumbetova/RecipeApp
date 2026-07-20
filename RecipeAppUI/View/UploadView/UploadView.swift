import SwiftUI

struct UploadView: View {
    @Environment(NavigatorCoordinator.self) var coordinator
    @State private var viewModel = UploadViewModel()
    @State private var localization = LocalizedManager.shared

    var body: some View {
        VStack{
            HStack{
                Button(localization.t("Cancel"),role: .destructive ){
                    coordinator.setRoot(.home)
                }
                .font(.h2)
                
                Spacer()
                
                Text("\(viewModel.currentStep)/")
                    .font(.h2)
                    .foregroundStyle(.appMainText)
                Text("2")
                    .font(.h2)
                    .foregroundStyle(.appSecondaryText)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 34)
            
            Group{
                if viewModel.currentStep == 1{
                    UploadStep1View(viewModel: viewModel)
                        
                }else{
                    UploadStep2View(viewModel: viewModel)
                }
                
            }
            .transition(.opacity.combined(with: .move(edge: viewModel.currentStep == 1 ? .leading : .trailing)))
            .animation(.easeInOut, value: viewModel.currentStep)
            
            BottomView(viewModel: viewModel)

        }
        .navigationBarBackButtonHidden(true)
        .alert(localization.t("Image required"),isPresented: $viewModel.showAlert){
            Button("Ok",role: .cancel){}
        }message:{
            Text(localization.t("Pls upload a recipe image before continuing to next step"))
        }
        .overlay{
            if viewModel.showSuccess{
                ZStack(alignment: .bottom){
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    SuccessSheetView{
                        viewModel.showSuccess = false
                        coordinator.setRoot(.home)
                    }
                    .transition(
                        .move(edge: .bottom)
                    )
                    
                }
                .ignoresSafeArea()
                .zIndex(1)
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.88 ),
            value: viewModel.showSuccess
        )
    }
}
#Preview {
    UploadView()
        .environment(NavigatorCoordinator())
}
