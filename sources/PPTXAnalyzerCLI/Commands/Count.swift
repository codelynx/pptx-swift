import ArgumentParser
import Foundation
import PPTXKit

struct Count: ParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Get the total number of slides in a PPTX file"
	)
	
	@Argument(help: "Path to the PPTX file")
	var file: String
	
	@Flag(name: .shortAndLong, help: "Minimal output (errors only)")
	var quiet = false
	
	@Option(name: .shortAndLong, help: "Write output to file instead of stdout")
	var output: String?
	
	mutating func run() throws {
		do {
			let document = try PPTXDocument(filePath: file)
			let count = try document.getSlideCount()
			
			// Output handling
			let output = "\(count)"
			
			if let outputFile = self.output {
				try output.write(toFile: outputFile, atomically: true, encoding: .utf8)
				if !quiet {
					print("Slide count written to: \(outputFile)")
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
}