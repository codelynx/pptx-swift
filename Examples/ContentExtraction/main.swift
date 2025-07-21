import Foundation
import PPTXKit

// Example demonstrating how to extract content from PowerPoint presentations

@main
struct ContentExtractor {
	static func main() async throws {
		// Get file path from command line arguments
		let arguments = CommandLine.arguments
		guard arguments.count > 1 else {
			print("Usage: ContentExtraction <path-to-pptx>")
			exit(1)
		}
		
		let filePath = arguments[1]
		let fileURL = URL(fileURLWithPath: filePath)
		
		do {
			// Load the presentation
			let document = try PPTXDocument(filePath: fileURL.path)
			
			print("=== Presentation Analysis ===\n")
			
			// Extract metadata
			let metadata = try document.getMetadata()
			print("📄 Metadata:")
			print("   Title: \(metadata.title ?? "Untitled")")
			print("   Author: \(metadata.author ?? "Unknown")")
			print("   Subject: \(metadata.subject ?? "None")")
			print("   Created: \(metadata.created?.formatted() ?? "Unknown")")
			print("   Modified: \(metadata.modified?.formatted() ?? "Unknown")")
			print("")
			
			// Get slide count
			let slideCount = try document.getSlideCount()
			print("📊 Total Slides: \(slideCount)")
			print("")
			
			// Extract text from each slide
			print("📝 Slide Content:")
			let slides = try document.getSlides()
			
			for slide in slides {
				print("\n--- Slide \(slide.index) ---")
				
				// Title
				if let title = slide.title {
					print("Title: \(title)")
				}
				
				// Text content
				if !slide.textContent.isEmpty {
					print("Content:")
					for (index, text) in slide.textContent.enumerated() {
						print("  \(index + 1). \(text)")
					}
				}
				
				// Shape count
				print("Shapes: \(slide.shapes.count)")
				
				// Image count
				let imageCount = slide.relationships.filter { $0.type.contains("image") }.count
				if imageCount > 0 {
					print("Images: \(imageCount)")
				}
			}
			
			print("\n=== Summary ===")
			let totalTextItems = slides.reduce(0) { $0 + $1.textContent.count }
			let totalShapes = slides.reduce(0) { $0 + $1.shapes.count }
			let totalImages = slides.reduce(0) { count, slide in
				count + slide.relationships.filter { $0.type.contains("image") }.count
			}
			
			print("Total text items: \(totalTextItems)")
			print("Total shapes: \(totalShapes)")
			print("Total images: \(totalImages)")
			
		} catch {
			print("Error: \(error)")
			exit(1)
		}
	}
}