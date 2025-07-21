import SwiftUI
import PPTXKit

#if os(macOS)
struct DocumentView: View {
	@Binding var document: PPTXDocumentWrapper
	@State private var sidebarSelection: String? = "presentation"
	
	var body: some View {
		NavigationSplitView {
			// Sidebar
			List(selection: $sidebarSelection) {
				Section("Views") {
					Label("Presentation", systemImage: "play.rectangle")
						.tag("presentation")
					Label("Thumbnails", systemImage: "square.grid.2x2")
						.tag("thumbnails")
					Label("Outline", systemImage: "list.bullet.indent")
						.tag("outline")
				}
				
				if document.manager.slideCount > 0 {
					Section("Slides") {
						ForEach(1...document.manager.slideCount, id: \.self) { index in
							HStack {
								Text("Slide \(index)")
								if index == document.manager.currentSlideIndex {
									Spacer()
									Image(systemName: "checkmark.circle.fill")
										.foregroundColor(.accentColor)
								}
							}
							.tag("slide-\(index)")
							.onTapGesture {
								document.manager.goToSlide(at: index)
								sidebarSelection = "slide-\(index)"
							}
						}
					}
				}
			}
			.navigationSplitViewColumnWidth(min: 200, ideal: 250)
		} detail: {
			// Main content area
			if document.manager.slideCount > 0 {
				switch sidebarSelection {
				case "presentation":
					PresentationMainView(manager: document.manager, sidebarSelection: $sidebarSelection)
				case "thumbnails":
					ThumbnailsMainView(manager: document.manager, sidebarSelection: $sidebarSelection)
				case "outline":
					OutlineMainView(manager: document.manager, sidebarSelection: $sidebarSelection)
				default:
					if let slideString = sidebarSelection,
					   slideString.hasPrefix("slide-"),
					   let index = Int(slideString.dropFirst(6)) {
						// Show specific slide
						VStack {
							if let slide = document.manager.slide(at: index), let pptxDocument = document.manager.document {
								PPTXSlideViewUI(document: pptxDocument, slideIndex: index)
									.renderingQuality(.high)
									.padding()
									.id(slide.id)
							}
						}
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color(NSColor.windowBackgroundColor))
					}
				}
			} else {
				// Empty state for new documents
				VStack(spacing: 20) {
					Image(systemName: "doc.richtext")
						.font(.system(size: 72))
						.foregroundColor(.secondary)
					
					Text("No Presentation Loaded")
						.font(.title)
						.fontWeight(.semibold)
					
					Text("This document appears to be empty or corrupted")
						.font(.body)
						.foregroundColor(.secondary)
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color(NSColor.windowBackgroundColor))
			}
		}
		.frame(minWidth: 800, minHeight: 600)
	}
}
#endif