import SwiftUI
import UniformTypeIdentifiers
import PPTXKit

#if os(macOS)
/// Document wrapper for PowerPoint files in macOS document-based app
struct PPTXDocumentWrapper: FileDocument {
	// Document type that can be opened
	static var readableContentTypes: [UTType] { [.pptx] }
	
	// The PPTXManager that handles the document
	var manager: PPTXManager
	
	// Initialize with a new empty document
	init() {
		self.manager = PPTXManager()
	}
	
	// Initialize by reading from a file
	init(configuration: ReadConfiguration) throws {
		guard let data = configuration.file.regularFileContents else {
			throw CocoaError(.fileReadCorruptFile)
		}
		
		// Create a temporary file to load the PPTX
		let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pptx")
		try data.write(to: tempURL)
		
		self.manager = PPTXManager()
		try self.manager.loadPresentation(from: tempURL.path)
		
		// Clean up temp file
		try? FileManager.default.removeItem(at: tempURL)
	}
	
	// Save the document (read-only for now)
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		// For now, we don't support saving/editing
		throw CocoaError(.fileWriteNoPermission)
	}
}

// Define the PPTX UTType
extension UTType {
	static var pptx: UTType {
		UTType(importedAs: "com.microsoft.powerpoint.pptx")
	}
}
#endif