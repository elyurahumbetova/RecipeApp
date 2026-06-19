import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .home
    @Environment(NavigatorCoordinator.self) var coordinator
    
    var body: some View {
        VStack() {
            
            switch selectedTab {
            case .home:
                HomeContentView()
            case .upload:
                UploadView()
            case .profile:
                ProfileView()
            }
            
            HStack{
                TabBarItem(icon: "house.fill", label: "Home", tab: .home, selectedTab: $selectedTab)
                    
                
                TabBarItem(icon: "pencil", label: "Upload", tab: .upload, selectedTab: $selectedTab){
                    coordinator.push(.uploadView)
                }
                    
                    
                
                TabBarItem(icon: "person",     label: "Profile",      tab: .profile,      selectedTab: $selectedTab)
                    
                
            }
            .frame(maxWidth: .infinity)
            
        }

    }
}
#Preview{
    HomeView()
        .environment(NavigatorCoordinator())
}
