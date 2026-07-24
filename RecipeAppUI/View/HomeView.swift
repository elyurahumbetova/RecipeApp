import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .home
    @Environment(NavigatorCoordinator.self) var coordinator
    @State private var localization = LocalizedManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(Tab.home)

            Color.clear
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Upload")
                }
                .tag(Tab.upload)

            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(Tab.profile)
        }
        .ignoresSafeArea(.container,edges: .bottom)
        .onChange(of: selectedTab){oldValue,newValue in
            if newValue == .upload{
                selectedTab = oldValue
                coordinator.push(.uploadView)
            }
            
        }
        .tint(.appPrimary)
    }
}
