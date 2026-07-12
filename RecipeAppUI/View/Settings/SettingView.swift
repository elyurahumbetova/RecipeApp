import SwiftUI
import FirebaseAuth

struct SettingView: View {
    @Environment(NavigatorCoordinator.self) private var coordinator
    @Environment(UserCoordinator.self) var userCoordinator
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"

    @State private var viewModel = SettingViewModel()
    @State private var localization = LocalizedManager.shared

    private let languages: [(code: String, name: String)] = [
        ("az", "Azərbaycan"),
        ("en", "English"),
        ("ru", "Русский"),
        ("tr", "Türkçe")
    ]
    
    private var selectedLanguageName: String{
        languages.first{
            $0.code == localization.currentLang
        }? .name ?? "English"
    }
        var body: some View {
            List {
                Section {
                    AppearanceRow(
                        icon: "sun.max.fill",
                        iconColor: .orange,
                        title: localization.t("Light Mode"),
                        isSelected: appColorScheme == "light"
                    ) {
                        appColorScheme = "light"
                    }
                    
                    AppearanceRow(
                        icon: "moon.fill",
                        iconColor: .black,
                        title: localization.t("Dark Mode"),
                        isSelected: appColorScheme == "dark"
                    ) {
                        appColorScheme = "dark"
                    }
                    
                    AppearanceRow(
                        icon: "iphone",
                        iconColor: .gray,
                        title: localization.t("System Default"),
                        isSelected: appColorScheme == "system"
                    ) {
                        appColorScheme = "system"
                    }
                } header: {
                    Text(localization.t("Appearance"))
                }
                
                Section {
                    Menu {
                        ForEach(languages, id: \.code) { language in
                            Button {
                                localization.currentLang = language.code
                            } label: {
                                if localization.currentLang == language.code {
                                    Label(language.name, systemImage: "checkmark")
                                } else {
                                    Text(language.name)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedLanguageName)
                                .font(.p1)
                                .foregroundStyle(.appMainText)

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.appMainText)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                } header: {
                    Text(localization.t("Language"))
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
                        Text(localization.t("Log Out"))
                            .foregroundColor(.red)
                            .font(.p1)
                    }
                }
            } header: {
                Text(localization.t("Account"))
            }
        }
        .navigationTitle(localization.t("Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .id(localization.currentLang)
        .alert(localization.t("Log Out"), isPresented: $viewModel.showLogoutAlert) {
            Button(localization.t("Log Out"), role: .destructive) {
                appColorScheme = viewModel.logout(
                    currentColorScheme: appColorScheme,
                    userCoordinator: userCoordinator,
                    coordinator: coordinator)
            }
            Button(localization.t("Cancel"), role: .cancel) {
                viewModel.cancelLogout()
            }
        } message: {
            Text(localization.t("Are you sure you want to log out?"))
        }
    }
}

struct AppearanceRow: View {
    let icon: String
    let iconColor: Color
    let title: String
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

                Text(verbatim: title)
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
