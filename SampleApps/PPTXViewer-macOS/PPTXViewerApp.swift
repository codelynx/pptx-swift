import SwiftUI

@main
struct PPTXViewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open...") {
                    NotificationCenter.default.post(
                        name: Notification.Name("OpenFile"),
                        object: nil
                    )
                }
                .keyboardShortcut("O", modifiers: .command)
            }
        }
    }
}