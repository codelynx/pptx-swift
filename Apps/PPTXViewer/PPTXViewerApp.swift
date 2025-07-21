import SwiftUI

@main
struct PPTXViewerApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				#if os(macOS)
				.frame(minWidth: 800, minHeight: 600)
				#endif
		}
		#if os(macOS)
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
		#endif
	}
}