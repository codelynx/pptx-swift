import SwiftUI
import PPTXKit

// MARK: - Presentation Main View

struct PresentationMainView: View {
	@ObservedObject var manager: PPTXManager
	@Binding var selectedDestination: NavigationDestination?
	
	var body: some View {
		VStack(spacing: 0) {
			// Toolbar
			HStack {
				Button(action: {
					manager.goToPrevious()
					updateSelectionIfNeeded()
				}) {
					Image(systemName: "chevron.left")
				}
				.disabled(!manager.canGoPrevious)
				#if os(macOS)
				.keyboardShortcut(.leftArrow, modifiers: [])
				#endif
				
				Text("Slide \(manager.currentSlideIndex) of \(manager.slideCount)")
					.font(.headline)
					.frame(minWidth: 150)
				
				Button(action: {
					manager.goToNext()
					updateSelectionIfNeeded()
				}) {
					Image(systemName: "chevron.right")
				}
				.disabled(!manager.canGoNext)
				#if os(macOS)
				.keyboardShortcut(.rightArrow, modifiers: [])
				#endif
				
				Spacer()
				
				if let metadata = manager.metadata, let title = metadata.title {
					Text(title)
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			.padding()
			#if os(macOS)
			.background(Color(NSColor.controlBackgroundColor))
			#else
			.background(Color(UIColor.secondarySystemBackground))
			#endif
			
			// Progress bar
			GeometryReader { geometry in
				Rectangle()
					.fill(Color.accentColor.opacity(0.3))
					.frame(width: geometry.size.width * manager.progress, height: 2)
			}
			.frame(height: 2)
			
			// Slide view
			PPTXPresentationView(manager: manager)
				.navigationControlsVisible(false)
				.progressBarVisible(false)
				.renderingQuality(.high)
		}
	}
	
	private func updateSelectionIfNeeded() {
		if case .slide = selectedDestination {
			selectedDestination = .slide(index: manager.currentSlideIndex)
		}
	}
}

// MARK: - Thumbnails Main View

struct ThumbnailsMainView: View {
	@ObservedObject var manager: PPTXManager
	@Binding var selectedDestination: NavigationDestination?
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)], spacing: 16) {
				ForEach(Array(manager.allSlides().enumerated()), id: \.element.id) { index, slide in
					ThumbnailView(
						manager: manager,
						slide: slide,
						index: index + 1,
						isSelected: manager.currentSlideIndex == index + 1
					) {
						manager.goToSlide(at: index + 1)
						selectedDestination = .slide(index: index + 1)
					}
				}
			}
			.padding()
		}
		#if os(macOS)
		.background(Color(NSColor.windowBackgroundColor))
		#else
		.background(Color(UIColor.systemBackground))
		#endif
	}
}

private struct ThumbnailView: View {
	let manager: PPTXManager
	let slide: Slide
	let index: Int
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			VStack(alignment: .leading, spacing: 8) {
				// Slide preview
				Group {
					if let document = manager.document {
						PPTXSlideViewUI(document: document, slideIndex: index)
							.renderingQuality(.low)
							.frame(height: 150)
					} else {
						PPTXSlideViewUI(slide: slide)
							.renderingQuality(.low)
							.frame(height: 150)
					}
				}
				#if os(macOS)
				.background(Color(NSColor.controlBackgroundColor))
				#else
				.background(Color(UIColor.secondarySystemGroupedBackground))
				#endif
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
				)
				.id(slide.id)
				
				// Slide info
				VStack(alignment: .leading, spacing: 4) {
					Text("Slide \(index)")
						.font(.headline)
					if let title = slide.title {
						Text(title)
							.font(.caption)
							.foregroundColor(.secondary)
							.lineLimit(2)
					}
				}
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
}

// MARK: - Outline Main View

struct OutlineMainView: View {
	@ObservedObject var manager: PPTXManager
	@Binding var selectedDestination: NavigationDestination?
	@State private var searchText = ""
	
	var body: some View {
		VStack(spacing: 0) {
			// Search bar
			HStack {
				Image(systemName: "magnifyingglass")
					.foregroundColor(.secondary)
				TextField("Search slides...", text: $searchText)
					#if os(macOS)
					.textFieldStyle(.plain)
					#else
					.textFieldStyle(.roundedBorder)
					#endif
			}
			.padding(8)
			#if os(macOS)
			.background(Color(NSColor.controlBackgroundColor))
			#else
			.background(Color(UIColor.secondarySystemBackground))
			#endif
			
			// Slide list
			List {
				ForEach(filteredSlides, id: \.id) { slide in
					SlideRowView(
						slide: slide,
						isCurrentSlide: slide.index == manager.currentSlideIndex,
						onTap: {
							manager.goToSlide(at: slide.index)
							selectedDestination = .slide(index: slide.index)
						}
					)
				}
			}
			#if os(iOS)
			.listStyle(.plain)
			#endif
		}
		#if os(macOS)
		.background(Color(NSColor.windowBackgroundColor))
		#else
		.background(Color(UIColor.systemBackground))
		#endif
	}
	
	private var filteredSlides: [Slide] {
		if searchText.isEmpty {
			return manager.allSlides()
		} else {
			return manager.searchSlides(containing: searchText)
		}
	}
}

struct SlideRowView: View {
	let slide: Slide
	let isCurrentSlide: Bool
	let onTap: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			// Header
			HStack {
				Text("Slide \(slide.index)")
					.font(.headline)
				if isCurrentSlide {
					Spacer()
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(.accentColor)
				}
			}
			
			// Title
			if let title = slide.title {
				Text(title)
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
			
			// Content preview
			let previewItems = Array(slide.textContent.prefix(3).enumerated())
			ForEach(previewItems, id: \.offset) { _, text in
				Text("• \(text)")
					.font(.caption)
					.foregroundColor(.secondary)
					.lineLimit(1)
			}
			
			if slide.textContent.count > 3 {
				Text("... and \(slide.textContent.count - 3) more items")
					.font(.caption)
					.foregroundColor(Color.secondary.opacity(0.5))
			}
		}
		.padding(.vertical, 4)
		.contentShape(Rectangle())
		.onTapGesture(perform: onTap)
	}
}

// MARK: - Presentation Info View

struct PresentationInfoView: View {
	@ObservedObject var manager: PPTXManager
	
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
				}
				.frame(maxWidth: .infinity)
				.padding()
			}
		}
	}
}