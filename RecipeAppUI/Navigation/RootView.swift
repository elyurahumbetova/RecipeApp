import SwiftUI

struct RootView: View {
    @State var coordinator = NavigatorCoordinator()
    @State private var userCoordinator = UserCoordinator()
    
    
    @AppStorage("appColorScheme") var appColorScheme : String = "system"
    
    var prefferedColorScheme: ColorScheme? {
        switch appColorScheme
        {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some View {
        @Bindable var coordinator = coordinator
        
        NavigationStack(path: $coordinator.path) {
            coordinator.root.getView()
                .navigationDestination(for: AppRoute.self) { route in
                    route.getView()
                }
        }
        .preferredColorScheme(prefferedColorScheme)
        .environment(coordinator)
        .environment(userCoordinator)
    }
}

extension AppRoute {
    @ViewBuilder
    func getView() -> some View {
        switch self {
        case .settingView: SettingView()
        case .splash: SplashView()
        case .onBoarding: OnBoarding()
        case .signIn: SignIn()
        case .signUp: SignUp()
        case .home: HomeView()
        case .uploadView: UploadView()
        
        case .detailView1(let recipe, ):
            DetailView1(recipe: recipe)
        
        }
    }
}
