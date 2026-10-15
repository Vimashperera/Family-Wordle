import SwiftUI

@main
struct FamilyWordleApp: App {
    @StateObject private var store = PersistenceStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
