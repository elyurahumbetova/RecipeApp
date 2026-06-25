//
//  TabBarItem.swift
//  RecipeAppUI
//
//  Created by Elyura on 26.03.26.
//

import SwiftUI

struct TabBarItem: View {
    let icon: String
    let label: String
    let tab: Tab
    @Binding var selectedTab: Tab
    var action: (() -> Void)? = nil
    var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button {
            if let action {
                action()
            } else {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? .appPrimary : .appOutline)
                Text(label)
                    .font(.s)
                    .foregroundStyle(isSelected ? .appPrimary : .appOutline)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TabBarItemPreview()
}

private struct TabBarItemPreview: View {
    @State var selectedTab: Tab = .home
    var body: some View {
        TabBarItem(icon: "house.fill", label: "home", tab: .home, selectedTab: $selectedTab)
    }
}
