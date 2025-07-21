import ArgumentParser
import Foundation
import PPTXKit

struct Info: ParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Get detailed information about a specific slide"
	)
	
	@Argument(help: "Path to the PPTX file")
	var file: String
	
	@Option(name: [.customShort("n"), .long], help: "Slide by 1-based index")
	var index: Int?
	
	@Option(help: "Slide by ID (e.g., 'slide1')")
	var id: String?
	
	@Flag(name: .shortAndLong, help: "Minimal output (errors only)")
	var quiet = false
	
	@Option(name: .shortAndLong, help: "Write output to file instead of stdout")
	var output: String?
	
	mutating func validate() throws {
		// Ensure exactly one of index or id is provided
		if (index == nil && id == nil) || (index != nil && id != nil) {
			throw ValidationError("Specify either --index or --id, not both")
		}
		
		if let index = index, index < 1 {
			throw ValidationError("Slide index must be 1 or greater")
		}
	}
	
	mutating func run() throws {
		do {
			let document = try PPTXDocument(filePath: file)
			
			let slide: Slide?
			if let index = index {
				slide = try document.getSlide(at: index)
			} else if let id = id {
				slide = try document.getSlide(withId: id)
			} else {
				// This shouldn't happen due to validation
				slide = nil
			}
			
			guard let slide = slide else {
				fputs("Error: Slide not found\n", stderr)
				throw ExitCode(4)
			}
			
			let output = formatSlideInfo(slide)
			
			// Output handling
			if let outputFile = self.output {
				try output.write(toFile: outputFile, atomically: true, encoding: .utf8)
				if !quiet {
					print("Slide info written to: \(outputFile)")
				}
			} else {
				print(output)
			}
		} catch let error as PPTXDocument.PPTXError {
			// Exit with appropriate error code
			switch error {
			case .fileNotFound:
				fputs("Error: \(error.localizedDescription)\n", stderr)
				throw ExitCode(1)
			case .invalidPPTXFile, .corruptedArchive:
				fputs("Error: \(error.localizedDescription)\n", stderr)
				throw ExitCode(2)
			case .missingRequiredFile, .invalidXML:
				fputs("Error: \(error.localizedDescription)\n", stderr)
				throw ExitCode(2)
			case .slideNotFound:
				fputs("Error: \(error.localizedDescription)\n", stderr)
				throw ExitCode(4)
			case .documentNotSet:
				fputs("Error: \(error.localizedDescription)\n", stderr)
				throw ExitCode(3)
			}
		} catch {
			fputs("Error: \(error.localizedDescription)\n", stderr)
			throw ExitCode(1)
		}
	}
	
	private func formatSlideInfo(_ slide: Slide) -> String {
		var lines: [String] = []
		
		lines.append("Slide Information")
		lines.append("=================")
		lines.append("ID: \(slide.id)")
		lines.append("Index: \(slide.index)")
		
		if let layout = slide.layoutType {
			lines.append("Layout: \(layout)")
		}
		
		if let title = slide.title {
			lines.append("Title: \(title)")
		}
		
		lines.append("Number of shapes: \(slide.shapeCount)")
		
		if !slide.textContent.isEmpty {
			lines.append("\nText Content:")
			lines.append("-------------")
			for (index, text) in slide.textContent.enumerated() {
				lines.append("\(index + 1). \(text)")
			}
		}
		
		if let notes = slide.notes, !notes.isEmpty {
			lines.append("\nNotes:")
			lines.append("------")
			lines.append(notes)
		}
		
		if !slide.relationships.isEmpty {
			lines.append("\nRelationships:")
			lines.append("--------------")
			
			var imageCount = 0
			var chartCount = 0
			var diagramCount = 0
			var mediaCount = 0
			var otherCount = 0
			
			for rel in slide.relationships {
				switch rel.type {
				case .image:
					imageCount += 1
				case .chart:
					chartCount += 1
				case .diagram:
					diagramCount += 1
				case .media:
					mediaCount += 1
				case .other:
					otherCount += 1
				}
			}
			
			if imageCount > 0 {
				lines.append("Images: \(imageCount)")
			}
			if chartCount > 0 {
				lines.append("Charts: \(chartCount)")
			}
			if diagramCount > 0 {
				lines.append("Diagrams: \(diagramCount)")
			}
			if mediaCount > 0 {
				lines.append("Media files: \(mediaCount)")
			}
			if otherCount > 0 {
				lines.append("Other relationships: \(otherCount)")
			}
		}
		
		return lines.joined(separator: "\n")
	}
}