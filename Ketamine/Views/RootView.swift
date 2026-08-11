import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: GestaltStore

    var body: some View {
        switch DeviceCompatibility.currentStatus {
        case .supported:
            MainTabView()
        case .unsupported(let reason):
            UnsupportedView(reason: reason)
        }
    }
}

// MARK: - Main tabs

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Tweaks", systemImage: "slider.horizontal.3") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
