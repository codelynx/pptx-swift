import Foundation
import PPTXKit
import ArgumentParser

struct TestImages: ParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Test image rendering in PPTX files"
	)
	
	@Argument(help: "Path to the PPTX file")
	var pptxPath: String
	
	@Option(name: .shortAndLong, help: "Maximum number of slides to test")
	var maxSlides: Int = 10
	
	func run() throws {
		let document = try PPTXDocument(filePath: pptxPath)
		print("Loaded PPTX: \(pptxPath)")
		
		let slideCount = try document.getSlideCount()
		print("Total slides: \(slideCount)")
		
		var slidesWithImages = 0
		var imagesRendered = 0
		
		for i in 1...min(slideCount, maxSlides) {
			guard let slide = try document.getSlide(at: i) else {
				continue
			}
			
			// Check for image relationships
			let imageRelationships = slide.relationships.filter {
				if case .image = $0.type { return true }
				return false
			}
			
			if !imageRelationships.isEmpty {
				slidesWithImages += 1
				print("\nSlide \(i) contains \(imageRelationships.count) image(s):")
				
				for rel in imageRelationships {
					print("  - ID: \(rel.id), Target: \(rel.target)")
				}
				
				// Try to render this slide
				let context = RenderingContext(
					size: CGSize(width: 1920, height: 1080),
					scale: 1.0,
					quality: .high
				)
				
				let renderer = SlideRenderer(context: context, archive: document.archive)
				do {
					let cgImage = try renderer.render(slide: slide)
					print("  ✓ Successfully rendered slide \(i) with images")
					print("    Image size: \(cgImage.width)x\(cgImage.height)")
					imagesRendered += imageRelationships.count
				} catch {
					print("  ✗ Failed to render slide \(i): \(error)")
				}
			}
		}
		
		print("\nSummary:")
		print("- Slides with images: \(slidesWithImages)")
		print("- Total images found and rendered: \(imagesRendered)")
		print("\nImage rendering test complete!")
	}
}