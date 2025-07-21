import SwiftUI
import PPTXKit
import UniformTypeIdentifiers

#if os(iOS)
struct ContentView: View {
	@StateObject private var manager = PPTXManager()
	@State private var showingFilePicker = false
	@State private var showingError = false
	@State private var errorMessage = ""
	@State private var selectedTab = 0
	
	var body: some View {
		TabView(selection: $selectedTab) {
			// Presentation View Tab
			NavigationView {
				VStack {
					if manager.slideCount > 0 {
						PPTXPresentationView(manager: manager)
							.navigationControlsVisible(true)
							.progressBarVisible(true)
							.renderingQuality(.high)
					} else {
						EmptyStateView {
							showingFilePicker = true
						}
					}
				}
				.navigationTitle("Presentation")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: { showingFilePicker = true }) {
							Image(systemName: "folder")
						}
					}
				}
			}
			.tabItem {
				Label("Presentation", systemImage: "play.rectangle")
			}
			.tag(0)
			
			// Thumbnails Tab
			NavigationView {
				VStack {
					if manager.slideCount > 0 {
						PPTXThumbnailGridView(manager: manager)
					} else {
						EmptyStateView {
							showingFilePicker = true
						}
					}
				}
				.navigationTitle("Slides")
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: { showingFilePicker = true }) {
							Image(systemName: "folder")
						}
					}
				}
			}
			.tabItem {
				Label("Thumbnails", systemImage: "square.grid.2x2")
			}
			.tag(1)
			
			// Info Tab
			NavigationView {
				PresentationInfoView(manager: manager)
					.navigationTitle("Info")
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button(action: { showingFilePicker = true }) {
								Image(systemName: "folder")
							}
						}
					}
			}
			.tabItem {
				Label("Info", systemImage: "info.circle")
			}
			.tag(2)
		}
		.fileImporter(
			isPresented: $showingFilePicker,
			allowedContentTypes: [UTType(filenameExtension: "pptx") ?? .data],
			allowsMultipleSelection: false
		) { result in
			handleFileSelection(result)
		}
		.alert("Error", isPresented: $showingError) {
			Button("OK") { }
		} message: {
			Text(errorMessage)
		}
	}
	
	private func handleFileSelection(_ result: Result<[URL], Error>) {
		switch result {
		case .success(let urls):
			guard let url = urls.first else { return }
			loadPresentation(from: url)
		case .failure(let error):
			errorMessage = error.localizedDescription
			showingError = true
		}
	}
	
	private func loadPresentation(from url: URL) {
		// Start accessing the security-scoped resource
		guard url.startAccessingSecurityScopedResource() else {
			errorMessage = "Cannot access file"
			showingError = true
			return
		}
		
		defer {
			url.stopAccessingSecurityScopedResource()
		}
		
		do {
			try manager.loadPresentation(from: url.path)
			selectedTab = 0 // Switch to presentation view
		} catch {
			errorMessage = error.localizedDescription
			showingError = true
		}
	}
}

struct EmptyStateView: View {
	let action: () -> Void
	
	var body: some View {
		VStack(spacing: 20) {
			Image(systemName: "doc.richtext")
				.font(.system(size: 72))
				.foregroundColor(.secondary)
			
			Text("No Presentation")
				.font(.title)
				.fontWeight(.semibold)
			
			Text("Open a PowerPoint file to get started")
				.font(.body)
				.foregroundColor(.secondary)
			
			Button(action: action) {
				Label("Open File", systemImage: "folder")
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
		}
		.padding()
	}
}

struct PresentationInfoView: View {
	@ObservedObject var manager: PPTXManager
	@State private var showingFilePicker = false
	
	var body: some View {
		Form {
			if manager.slideCount > 0 {
				Section("Presentation") {
					LabeledContent("Slides", value: "\(manager.slideCount)")
					if let metadata = manager.metadata {
						if let title = metadata.title {
							LabeledContent("Title", value: title)
						}
						if let author = metadata.author {
							LabeledContent("Author", value: author)
						}
						if let created = metadata.created {
							LabeledContent("Created", value: created, format: .dateTime)
						}
						if let modified = metadata.modified {
							LabeledContent("Modified", value: modified, format: .dateTime)
						}
					}
				}
				
				Section("Current Slide") {
					LabeledContent("Index", value: "\(manager.currentSlideIndex)")
					if let slide = manager.currentSlide {
						if let title = slide.title {
							LabeledContent("Title", value: title)
						}
						LabeledContent("Shapes", value: "\(slide.shapeCount)")
						LabeledContent("Text Items", value: "\(slide.textContent.count)")
					}
				}
				
				Section("Navigation") {
					HStack {
						Button("First") {
							manager.goToFirst()
						}
						.disabled(!manager.canGoPrevious)
						
						Spacer()
						
						Button("Previous") {
							manager.goToPrevious()
						}
						.disabled(!manager.canGoPrevious)
						
						Spacer()
						
						Button("Next") {
							manager.goToNext()
						}
						.disabled(!manager.canGoNext)
						
						Spacer()
						
						Button("Last") {
							manager.goToLast()
						}
						.disabled(!manager.canGoNext)
					}
					.buttonStyle(.bordered)
				}
			} else {
				VStack(spacing: 20) {
					Text("No presentation loaded")
						.foregroundColor(.secondary)
					Button("Open File") {
						showingFilePicker = true
					}
					.buttonStyle(.borderedProminent)
				}
				.frame(maxWidth: .infinity)
				.padding()
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
#endif