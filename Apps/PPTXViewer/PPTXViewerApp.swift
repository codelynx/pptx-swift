import SwiftUI

@main
struct PPTXViewerApp: App {
	var body: some Scene {
		#if os(iOS)
		WindowGroup {
			ContentView()
		}
		#else
		DocumentGroup(newDocument: PPTXDocumentWrapper()) { file in
			DocumentView(document: file.$document)
		}
		#endif
	}
}