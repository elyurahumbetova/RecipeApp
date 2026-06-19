import SwiftUI
import FirebaseAuth
struct SettingView: View {
    @Environment(NavigatorCoordinator.self) private var coordinator
    @Environment(UserCoordinator.self) var userCoordinator
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    
    @State private var showLogoutAlert = false

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

            Section {
                Button {
                    showLogoutAlert = true
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
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Log Out", role: .destructive) {
                do{
                    try Auth.auth().signOut()
                    // əvvəlki temaı user ID-yə bağlı saxla
                           let userId = userCoordinator.user?.uid ?? ""
                           UserDefaults.standard.set(appColorScheme, forKey: "appColorScheme_\(userId)")
                    appColorScheme = "system"
                    userCoordinator.user = nil
                    coordinator.setRoot(.signIn)
                }
                catch{
                    print("Logout Error: \(error)")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
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

#Preview {
    SettingView()
        .environment(NavigatorCoordinator())
}
