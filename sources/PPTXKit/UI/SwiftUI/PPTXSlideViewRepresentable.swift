import SwiftUI

/// SwiftUI view for rendering PPTX slides
public struct PPTXSlideViewUI: View {
	private let slide: Slide?
	private let document: PPTXDocument?
	private let slideIndex: Int?
	private let slideId: String?
	
	@State private var renderingScale: CGFloat = 1.0
	@State private var renderingQuality: RenderingQuality = .balanced
	
	/// Initialize with a slide
	public init(slide: Slide) {
		self.slide = slide
		self.document = nil
		self.slideIndex = nil
		self.slideId = nil
	}
	
	/// Initialize with document and slide index
	public init(document: PPTXDocument, slideIndex: Int) {
		self.slide = nil
		self.document = document
		self.slideIndex = slideIndex
		self.slideId = nil
	}
	
	/// Initialize with document and slide ID
	public init(document: PPTXDocument, slideId: String) {
		self.slide = nil
		self.document = document
		self.slideIndex = nil
		self.slideId = slideId
	}
	
	public var body: some View {
		PPTXSlideViewRepresentable(
			slide: slide,
			document: document,
			slideIndex: slideIndex,
			slideId: slideId,
			renderingScale: renderingScale,
			renderingQuality: renderingQuality
		)
	}
	
	/// Set rendering scale
	public func renderingScale(_ scale: CGFloat) -> PPTXSlideViewUI {
		var view = self
		view._renderingScale = State(initialValue: scale)
		return view
	}
	
	/// Set rendering quality
	public func renderingQuality(_ quality: RenderingQuality) -> PPTXSlideViewUI {
		var view = self
		view._renderingQuality = State(initialValue: quality)
		return view
	}
}

// MARK: - Platform-specific representable

#if canImport(UIKit)
import UIKit

struct PPTXSlideViewRepresentable: UIViewRepresentable {
	let slide: Slide?
	let document: PPTXDocument?
	let slideIndex: Int?
	let slideId: String?
	let renderingScale: CGFloat
	let renderingQuality: RenderingQuality
	
	func makeUIView(context: Context) -> PPTXSlideView {
		let view: PPTXSlideView
		
		if let slide = slide {
			view = PPTXSlideView(slide: slide, frame: .zero)
		} else if let document = document, let index = slideIndex {
			view = PPTXSlideView(document: document, slideIndex: index)
		} else if let document = document, let id = slideId {
			view = PPTXSlideView(document: document, slideId: id)
		} else {
			// Empty view
			view = PPTXSlideView(frame: .zero)
		}
		
		view.renderingScale = renderingScale
		view.renderingQuality = renderingQuality
		
		return view
	}
	
	func updateUIView(_ uiView: PPTXSlideView, context: Context) {
		uiView.renderingScale = renderingScale
		uiView.renderingQuality = renderingQuality
		uiView.setNeedsRender()
	}
}

#elseif canImport(AppKit)
import AppKit

struct PPTXSlideViewRepresentable: NSViewRepresentable {
	let slide: Slide?
	let document: PPTXDocument?
	let slideIndex: Int?
	let slideId: String?
	let renderingScale: CGFloat
	let renderingQuality: RenderingQuality
	
	func makeNSView(context: Context) -> PPTXSlideView {
		let view: PPTXSlideView
		
		if let slide = slide {
			view = PPTXSlideView(slide: slide, frame: .zero)
		} else if let document = document, let index = slideIndex {
			view = PPTXSlideView(document: document, slideIndex: index)
		} else if let document = document, let id = slideId {
			view = PPTXSlideView(document: document, slideId: id)
		} else {
			// Empty view
			view = PPTXSlideView(frame: .zero)
		}
		
		view.renderingScale = renderingScale
		view.renderingQuality = renderingQuality
		
		return view
	}
	
	func updateNSView(_ nsView: PPTXSlideView, context: Context) {
		nsView.renderingScale = renderingScale
		nsView.renderingQuality = renderingQuality
		nsView.setNeedsRender()
	}
}
#endif

// MARK: - Preview

struct PPTXSlideViewUI_Previews: PreviewProvider {
	static var previews: some View {
		// Example preview with mock slide
		let mockSlide = Slide(
			id: "slide1",
			index: 1,
			layoutType: "Title Slide",
			title: "Sample Presentation",
			shapeCount: 3,
			notes: nil,
			relationships: [],
			textContent: ["Welcome to the presentation", "Subtitle text here"]
		)
		
		PPTXSlideViewUI(slide: mockSlide)
			.renderingQuality(.high)
			.frame(width: 400, height: 300)
			.previewLayout(.sizeThatFits)
	}
}