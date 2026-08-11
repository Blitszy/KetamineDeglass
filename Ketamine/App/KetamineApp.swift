import SwiftUI

@main
struct KetamineApp: App {
    @StateObject private var store = GestaltStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
                .tint(Theme.accent)
        }
    }
}
