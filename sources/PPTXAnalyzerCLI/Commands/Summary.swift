import ArgumentParser
import Foundation
import PPTXKit

struct Summary: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Get overall presentation summary"
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
            let metadata = try document.getMetadata()
            
            let output = formatSummary(metadata: metadata, filePath: file)
            
            // Output handling
            if let outputFile = self.output {
                try output.write(toFile: outputFile, atomically: true, encoding: .utf8)
                if !quiet {
                    print("Summary written to: \(outputFile)")
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
    
    private func formatSummary(metadata: PresentationMetadata, filePath: String) -> String {
        var lines: [String] = []
        
        lines.append("Presentation Summary")
        lines.append("===================")
        lines.append("File: \(filePath)")
        
        if let title = metadata.title {
            lines.append("Title: \(title)")
        }
        
        if let author = metadata.author {
            lines.append("Author: \(author)")
        }
        
        if let company = metadata.company {
            lines.append("Company: \(company)")
        }
        
        lines.append("")
        lines.append("Statistics:")
        lines.append("-----------")
        lines.append("Total slides: \(metadata.slideCount)")
        
        if metadata.masterCount > 0 {
            lines.append("Slide masters: \(metadata.masterCount)")
        }
        
        if !metadata.layoutsUsed.isEmpty {
            lines.append("Layouts used: \(metadata.layoutsUsed.count)")
            for layout in metadata.layoutsUsed.sorted() {
                lines.append("  - \(layout)")
            }
        }
        
        if metadata.mediaCount > 0 {
            lines.append("Media assets: \(metadata.mediaCount)")
        }
        
        lines.append("")
        lines.append("Metadata:")
        lines.append("---------")
        
        if let created = metadata.created {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            lines.append("Created: \(formatter.string(from: created))")
        }
        
        if let modified = metadata.modified {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            lines.append("Modified: \(formatter.string(from: modified))")
        }
        
        if let application = metadata.application {
            var appInfo = "Application: \(application)"
            if let version = metadata.appVersion {
                appInfo += " (v\(version))"
            }
            lines.append(appInfo)
        }
        
        // File size
        if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: filePath),
           let fileSize = fileAttributes[.size] as? Int64 {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            lines.append("File size: \(formatter.string(fromByteCount: fileSize))")
        }
        
        return lines.joined(separator: "\n")
    }
}