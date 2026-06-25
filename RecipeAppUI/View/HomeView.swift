import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .home
    @Environment(NavigatorCoordinator.self) var coordinator
    
    var body: some View {
        VStack {
            ZStack {
                HomeContentView()
                    .opacity(selectedTab == .home ? 1:0)
                    .zIndex(selectedTab == .home ? 1:0)
                
                ProfileView()
                    .opacity(selectedTab == .profile ? 1:0)
                    .zIndex(selectedTab == .profile ? 1:0)
            }
            
            HStack {
                TabBarItem(icon: "house.fill", label: "Home", tab: .home, selectedTab: $selectedTab)
                TabBarItem(icon: "pencil", label: "Upload", tab: .upload, selectedTab: $selectedTab) {
                    coordinator.push(.uploadView)
                }
                TabBarItem(icon: "person", label: "Profile", tab: .profile, selectedTab: $selectedTab)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
