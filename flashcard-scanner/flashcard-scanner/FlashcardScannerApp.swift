import SwiftUI

@main
struct FlashcardScannerApp: App { // Correct usage of @main
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
