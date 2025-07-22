import SwiftUI
import PPTXKit

/// Navigation destinations for the document viewer
enum NavigationDestination: Hashable {
	case presentation
	case thumbnails
	case outline
	case slide(index: Int)
}

/// Unified document view that works on both iOS and macOS using NavigationSplitView
struct UnifiedDocumentView: View {
	@Binding var document: PPTXDocumentWrapper
	@State private var selectedDestination: NavigationDestination? = .presentation
	@State private var columnVisibility = NavigationSplitViewVisibility.all
	
	var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			// Sidebar
			sidebarContent
				.navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 400)
		} detail: {
			// Detail view
			detailView
		}
		.navigationSplitViewStyle(.balanced)
		#if os(macOS)
		.frame(minWidth: 800, minHeight: 600)
		.toolbar {
			ToolbarItem(placement: .navigation) {
				Button(action: toggleSidebar) {
					Image(systemName: "sidebar.left")
				}
			}
		}
		#endif
	}
	
	// MARK: - Helper Functions
	
	#if os(macOS)
	private func toggleSidebar() {
		if columnVisibility == .all {
			columnVisibility = .detailOnly
		} else {
			columnVisibility = .all
		}
	}
	#endif
	
	// MARK: - Sidebar
	
	private var sidebarContent: some View {
		List(selection: $selectedDestination) {
			Section("Views") {
				NavigationLink(value: NavigationDestination.presentation) {
					Label("Presentation", systemImage: "play.rectangle")
				}
				.tag(NavigationDestination.presentation)
				
				NavigationLink(value: NavigationDestination.thumbnails) {
					Label("Thumbnails", systemImage: "square.grid.2x2")
				}
				.tag(NavigationDestination.thumbnails)
				
				NavigationLink(value: NavigationDestination.outline) {
					Label("Outline", systemImage: "list.bullet.indent")
				}
				.tag(NavigationDestination.outline)
			}
			
			if document.manager.slideCount > 0 {
				Section("Slides") {
					ForEach(1...document.manager.slideCount, id: \.self) { index in
						NavigationLink(value: NavigationDestination.slide(index: index)) {
							HStack {
								Text("Slide \(index)")
								if index == document.manager.currentSlideIndex {
									Spacer()
									Image(systemName: "checkmark.circle.fill")
										.foregroundColor(.accentColor)
								}
							}
						}
						.tag(NavigationDestination.slide(index: index))
					}
				}
			}
		}
		#if os(iOS)
		.listStyle(.insetGrouped)
		.navigationTitle("Presentation")
		.navigationBarTitleDisplayMode(.large)
		#else
		.listStyle(.sidebar)
		#endif
		.onChange(of: selectedDestination) { newValue in
			// Handle slide navigation
			if case .slide(let index) = newValue {
				document.manager.goToSlide(at: index)
			}
		}
	}
	
	// MARK: - Detail View
	
	private var detailView: some View {
		detailViewForDestination(selectedDestination ?? .presentation)
	}
	
	private func detailViewForDestination(_ destination: NavigationDestination) -> some View {
		Group {
			if document.manager.slideCount > 0 {
				switch destination {
				case .presentation:
					PresentationMainView(
						manager: document.manager,
						selectedDestination: $selectedDestination
					)
				case .thumbnails:
					ThumbnailsMainView(
						manager: document.manager,
						selectedDestination: $selectedDestination
					)
				case .outline:
					OutlineMainView(
						manager: document.manager,
						selectedDestination: $selectedDestination
					)
				case .slide(let index):
					SlideDetailView(
						manager: document.manager,
						slideIndex: index
					)
				}
			} else {
				EmptyStateView()
			}
		}
	}
}

// MARK: - Slide Detail View

struct SlideDetailView: View {
	let manager: PPTXManager
	let slideIndex: Int
	
	var body: some View {
		VStack {
			if let slide = manager.slide(at: slideIndex), let document = manager.document {
				PPTXSlideViewUI(document: document, slideIndex: slideIndex)
					.renderingQuality(.high)
					.padding()
					.id(slide.id)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		#if os(macOS)
		.background(Color(NSColor.windowBackgroundColor))
		#else
		.background(Color(UIColor.systemBackground))
		#endif
	}
}

// MARK: - Empty State

struct EmptyStateView: View {
	var body: some View {
		VStack(spacing: 20) {
			Image(systemName: "doc.richtext")
				.font(.system(size: 72))
				.foregroundColor(.secondary)
			
			Text("No Presentation Loaded")
				.font(.title)
				.fontWeight(.semibold)
			
			Text("The document appears to be empty or corrupted")
				.font(.body)
				.foregroundColor(.secondary)
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		#if os(macOS)
		.background(Color(NSColor.windowBackgroundColor))
		#else
		.background(Color(UIColor.systemBackground))
		#endif
	}
}