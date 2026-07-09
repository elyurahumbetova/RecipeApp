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
        .sheet(isPresented: $viewModel.showSuccess){
            SuccessSheetView{
                coordinator.setRoot(.home)
                viewModel.showSuccess = false
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(24)
        }
    }
}
#Preview {
    UploadView()
        .environment(NavigatorCoordinator())
}
