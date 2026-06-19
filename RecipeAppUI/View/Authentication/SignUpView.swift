import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUp: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var userName: String = ""

    @Environment(NavigatorCoordinator.self) var coordinator
    @Environment(UserCoordinator.self) var userCoordinator  

    var hasMinLength: Bool { password.count >= 8 }
    var hasNumber: Bool { password.contains(where: \.isNumber) }
    var isFormValid: Bool { hasMinLength && hasNumber && !email.isEmpty }

    var body: some View {
        VStack(spacing: 8) {
            Text("Welcome!")
                .font(.h1)
                .foregroundStyle(.appMainText)
            Text("Please, enter your account here")
                .font(.p2)
                .foregroundStyle(.appSecondaryText)
                .padding(.bottom, 24)

            AppTextField(type: .email, text: $email)
                .padding(.bottom, 8)
                .autocapitalization(.none)
            AppTextField(type: .password, text: $password)
                .padding(.bottom, 8)

            AppTextField(type: .other(placeholder: "Username", leadingIcon: "person.circle"), text: $userName)
                .padding(.bottom, 18)


            VStack(alignment: .leading) {
                Text("Your password must contain:")
                    .padding(.bottom, 8)
                    .font(.p1)

                requirementRows(text: "Atleast 8 characters", isMet: hasMinLength)
                    .padding(.bottom, 8)
                requirementRows(text: "Contains a number", isMet: hasNumber)
                    .padding(.bottom, 32)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.p2)
                        .padding(.bottom, 8)
                }

                AppButton(
                    title: isLoading ? "Signing Up..." : "Sign Up",
                    variant: .primaryFilled,
                    size: .regular
                ) {
                    register()
                }
                .disabled(!isFormValid || isLoading)
            }
        }
        .padding(24)
    }

    func register() {
        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in

            if let error = error {
                DispatchQueue.main.async{
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
               
            }

            guard let user = result?.user else {
                DispatchQueue.main.async{
                    self.isLoading = false
                }
                return }

            let db = Firestore.firestore()
            let profileData: [String: Any]=[
                "uid": user.uid,
                "username": userName,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]
            db.collection("profile").document(user.uid).setData(profileData) { error in
                       DispatchQueue.main.async {
                           self.isLoading = false

                           if let error = error {
                               self.errorMessage = error.localizedDescription
                               return
                           }

                           self.userCoordinator.user = user
                       }
                   }
        }
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
            .environment(UserCoordinator()) // ✅ added
    }
}
