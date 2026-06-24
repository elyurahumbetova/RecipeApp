import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUp: View {
   

    @Environment(NavigatorCoordinator.self) var coordinator
    @Environment(UserCoordinator.self) var userCoordinator  

    @State private var viewModel = SignUpViewModel()
    var body: some View {
        VStack(spacing: 8) {
            Text("Welcome!")
                .font(.h1)
                .foregroundStyle(.appMainText)
            Text("Please, enter your account here")
                .font(.p2)
                .foregroundStyle(.appSecondaryText)
                .padding(.bottom, 24)

            AppTextField(type: .email, text: $viewModel.email)
                .padding(.bottom, 8)
                .autocapitalization(.none)
            AppTextField(type: .password, text: $viewModel.password)
                .padding(.bottom, 8)

            AppTextField(type: .other(placeholder: "Username", leadingIcon: "person.circle"), text: $viewModel.userName)
                .padding(.bottom, 18)


            VStack(alignment: .leading) {
                Text("Your password must contain:")
                    .padding(.bottom, 8)
                    .font(.p1)

                requirementRows(text: "Atleast 8 characters", isMet: viewModel.hasMinLength)
                    .padding(.bottom, 8)
                requirementRows(text: "Contains a number", isMet: viewModel.hasNumber)
                    .padding(.bottom, 32)

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .font(.p2)
                        .padding(.bottom, 8)
                }

                AppButton(
                    title: viewModel.isLoading ? "Signing Up..." : "Sign Up",
                    variant: .primaryFilled,
                    size: .regular
                ) {
                    Task{
                        await register()

                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
            }
        }
        .padding(24)
    }

    private func register() async {
        guard let user = await viewModel.register() else{ return }
        userCoordinator.user = user
        coordinator.push(.home)
    }

    func requirementRows(text: String, isMet: Bool) -> some View {
        let bgColor = isMet ? Color(UIColor(rgb: 0xE3FFF1)) : Color.appSecondaryText.opacity(0.15)
        return HStack {
            Image(systemName: "checkmark")
                .foregroundStyle(isMet ? .appPrimary : .appSecondaryText)
                .padding(6)
                .background(bgColor)
                .clipShape(Circle())

            Text(text)
                .foregroundColor(isMet ? .appMainText : .appSecondaryText)
                .font(.p2)
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}

#Preview {
    NavigationStack {
        SignUp()
            .environment(NavigatorCoordinator())
            .environment(UserCoordinator()) 
    }
}
