import SwiftUI

@main
struct PPTXViewerApp: App {
	var body: some Scene {
		DocumentGroup(viewing: PPTXDocumentWrapper.self) { file in
			UnifiedDocumentView(document: file.$document)
		}
	}
}