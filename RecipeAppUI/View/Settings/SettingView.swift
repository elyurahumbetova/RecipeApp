import SwiftUI
import FirebaseAuth
struct SettingView: View {
    @Environment(NavigatorCoordinator.self) private var coordinator
    @Environment(UserCoordinator.self) var userCoordinator
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    
    @State private var viewModel = SettingViewModel()
    @Environment(LocalizedManager.self) private var localization
    
    private let languages:[(code: String,name: String)] = [
        ("az", "Azərbaycan"),
        ("en", "English"),
        ("ru", "Русский"),
        ("tr", "Turkce")

    ]
    var body: some View {
        List {
            
            Section {
                AppearanceRow(
                    icon: "sun.max.fill",
                    iconColor: .orange,
                    title: "Light Mode",
                    isSelected: appColorScheme == "light"
                ) {
                    appColorScheme = "light"
                }

                AppearanceRow(
                    icon: "moon.fill",
                    iconColor: .black,
                    title: "Dark Mode",
                    isSelected: appColorScheme == "dark"
                ) {
                    appColorScheme = "dark"
                }

                AppearanceRow(
                    icon: "iphone",
                    iconColor: .gray,
                    title: "System Default",
                    isSelected: appColorScheme == "system"
                ) {
                    appColorScheme = "system"
                }
            } header: {
                Text("Appearance")
            }

            Section{
                ForEach(languages, id: \.code){language in
                    AppearanceRow(
                        icon: "globe",
                        iconColor: .blue,
                        title: LocalizedStringKey(language.name),
                        isSelected: localization.currentLang == language.code )
                    {
                        localization.currentLang = language.code
                    }
                }
            }header: {
                Text("Language")
            }
            
            Section {
                Button {
                    viewModel.requestLogout()
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red)
                                .frame(width: 32, height: 32)
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Text("Log Out")
                            .foregroundColor(.red)
                            .font(.p1)
                    }
                }
            } header: {
                Text("Account")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Log Out", isPresented: $viewModel.showLogoutAlert) {
            Button("Log Out", role: .destructive) {
                appColorScheme = viewModel.logout(
                    currentColorScheme: appColorScheme,
                    userCoordinator: userCoordinator,
                    coordinator: coordinator)
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelLogout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}


struct AppearanceRow: View {
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }

                Text(title)
                    .foregroundColor(.appMainText)
                    .font(.p1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.appPrimary)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }
}

//#Preview {
//    SettingView()
//        .environment(NavigatorCoordinator())
//}
