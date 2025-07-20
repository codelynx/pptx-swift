import ArgumentParser
import Foundation
import PPTXKit

struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List all slides in a PPTX file"
    )
    
    enum OutputFormat: String, ExpressibleByArgument {
        case simple
        case json
        case table
    }
    
    @Argument(help: "Path to the PPTX file")
    var file: String
    
    @Option(help: "Output format")
    var format: OutputFormat = .simple
    
    @Flag(name: .shortAndLong, help: "Include additional metadata")
    var verbose = false
    
    @Flag(name: .shortAndLong, help: "Minimal output (errors only)")
    var quiet = false
    
    @Option(name: .shortAndLong, help: "Write output to file instead of stdout")
    var output: String?
    
    mutating func run() throws {
        do {
            let document = try PPTXDocument(filePath: file)
            let slides = try document.getSlides()
            
            let output: String
            
            switch format {
            case .simple:
                output = formatSimple(slides: slides, verbose: verbose)
            case .json:
                output = try formatJSON(slides: slides)
            case .table:
                output = formatTable(slides: slides, verbose: verbose)
            }
            
            // Output handling
            if let outputFile = self.output {
                try output.write(toFile: outputFile, atomically: true, encoding: .utf8)
                if !quiet {
                    print("Slide list written to: \(outputFile)")
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
            }
        } catch {
            fputs("Error: \(error.localizedDescription)\n", stderr)
            throw ExitCode(1)
        }
    }
    
    private func formatSimple(slides: [Slide], verbose: Bool) -> String {
        if slides.isEmpty {
            return "No slides found"
        }
        
        return slides.map { slide in
            if verbose {
                let layout = slide.layoutType ?? "Unknown Layout"
                let title = slide.title.map { " \"\($0)\"" } ?? ""
                return "\(slide.index): \(slide.id) [\(layout)]\(title)"
            } else {
                return "\(slide.index): \(slide.id)"
            }
        }.joined(separator: "\n")
    }
    
    private func formatJSON(slides: [Slide]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let slideData = slides.map { slide in
            [
                "index": slide.index,
                "id": slide.id,
                "layoutType": slide.layoutType ?? "",
                "title": slide.title ?? ""
            ] as [String: Any]
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: slideData, options: [.prettyPrinted, .sortedKeys])
        return String(data: jsonData, encoding: .utf8) ?? "[]"
    }
    
    private func formatTable(slides: [Slide], verbose: Bool) -> String {
        if slides.isEmpty {
            return "No slides found"
        }
        
        var lines: [String] = []
        
        if verbose {
            // Header
            lines.append("Index | ID       | Layout           | Title")
            lines.append("------|----------|------------------|------")
            
            // Rows
            for slide in slides {
                let layout = slide.layoutType ?? "Unknown"
                let title = slide.title ?? ""
                lines.append(String(format: "%-5d | %-8s | %-16s | %s",
                                  slide.index, slide.id, layout, title))
            }
        } else {
            // Header
            lines.append("Index | ID")
            lines.append("------|----------")
            
            // Rows
            for slide in slides {
                lines.append(String(format: "%-5d | %s", slide.index, slide.id))
            }
        }
        
        return lines.joined(separator: "\n")
    }
}