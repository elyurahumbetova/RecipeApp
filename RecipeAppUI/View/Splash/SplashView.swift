import SwiftUI

struct SplashView: View {
    @Environment(NavigatorCoordinator.self) var coordinator
    @Environment(UserCoordinator.self) var userCoordinator

    @State private var showRecipe = false
    @State private var showApp = false

    var body: some View {
        ZStack {
            Color.appPrimary
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                Text("Recipe")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: showRecipe ? 0 : 200)
                    .opacity(showRecipe ? 1 : 0)

                Text("App")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: showApp ? 0 : 40)
                    .opacity(showApp ? 1 : 0)
            }
        }
        .task {
            withAnimation(.spring(duration: 0.6)) {
                showRecipe = true
            }

            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.spring(duration: 0.6)) {
                showApp = true
            }

            try? await Task.sleep(for: .seconds(2))
            checkAuthStatus()
        }
    }

    private func checkAuthStatus() {
        if userCoordinator.user == nil {
            coordinator.setRoot(.onBoarding)
        } else {
            coordinator.setRoot(.home)
        }
    }
}

#Preview {
    SplashView()
        .environment(NavigatorCoordinator())
        .environment(UserCoordinator())
}
