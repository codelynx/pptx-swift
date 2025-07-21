import SwiftUI
import PPTXKit

#if os(macOS)
struct PresentationMainView: View {
	@ObservedObject var manager: PPTXManager
	@Binding var sidebarSelection: String?
	
	var body: some View {
		VStack(spacing: 0) {
			// Toolbar
			HStack {
				Button(action: {
					print("⬅️ Previous button pressed")
					manager.goToPrevious()
					if sidebarSelection?.hasPrefix("slide-") == true {
						sidebarSelection = "slide-\(manager.currentSlideIndex)"
						print("   → Updated sidebar selection to: \(sidebarSelection ?? "nil")")
					}
				}) {
					Image(systemName: "chevron.left")
				}
				.disabled(!manager.canGoPrevious)
				.keyboardShortcut(.leftArrow, modifiers: [])
				
				Text("Slide \(manager.currentSlideIndex) of \(manager.slideCount)")
					.font(.headline)
					.frame(minWidth: 150)
				
				Button(action: {
					print("➡️ Next button pressed")
					manager.goToNext()
					if sidebarSelection?.hasPrefix("slide-") == true {
						sidebarSelection = "slide-\(manager.currentSlideIndex)"
						print("   → Updated sidebar selection to: \(sidebarSelection ?? "nil")")
					}
				}) {
					Image(systemName: "chevron.right")
				}
				.disabled(!manager.canGoNext)
				.keyboardShortcut(.rightArrow, modifiers: [])
				
				Spacer()
				
				if let metadata = manager.metadata, let title = metadata.title {
					Text(title)
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			.padding()
			.background(Color(NSColor.controlBackgroundColor))
			
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
}

struct ThumbnailsMainView: View {
	@ObservedObject var manager: PPTXManager
	@Binding var sidebarSelection: String?
	
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
						sidebarSelection = "slide-\(index + 1)"
					}
				}
			}
			.padding()
		}
		.background(Color(NSColor.windowBackgroundColor))
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
					.background(Color(NSColor.controlBackgroundColor))
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
}

struct OutlineMainView: View {
	@ObservedObject var manager: PPTXManager
	@Binding var sidebarSelection: String?
	@State private var searchText = ""
	
	var body: some View {
		VStack(spacing: 0) {
			searchBar
			slideList
		}
	}
	
	private var searchBar: some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.foregroundColor(.secondary)
			TextField("Search slides...", text: $searchText)
				.textFieldStyle(.plain)
		}
		.padding(8)
		.background(Color(NSColor.controlBackgroundColor))
	}
	
	private var slideList: some View {
		List {
			ForEach(filteredSlides, id: \.id) { slide in
				SlideRowView(
					slide: slide,
					isCurrentSlide: slide.index == manager.currentSlideIndex,
					onTap: {
						manager.goToSlide(at: slide.index)
						sidebarSelection = "slide-\(slide.index)"
					}
				)
			}
		}
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
			headerView
			titleView
			contentPreview
		}
		.padding(.vertical, 4)
		.contentShape(Rectangle())
		.onTapGesture(perform: onTap)
	}
	
	private var headerView: some View {
		HStack {
			Text("Slide \(slide.index)")
				.font(.headline)
			if isCurrentSlide {
				Spacer()
				Image(systemName: "checkmark.circle.fill")
					.foregroundColor(.accentColor)
			}
		}
	}
	
	@ViewBuilder
	private var titleView: some View {
		if let title = slide.title {
			Text(title)
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
	}
	
	@ViewBuilder
	private var contentPreview: some View {
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
}
#endif