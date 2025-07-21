import ArgumentParser
import Foundation
import PPTXKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct RenderCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "render",
        abstract: "Render a slide to an image file"
    )
    
    @Argument(help: "Path to the PowerPoint file")
    var pptxPath: String
    
    @Option(name: .customLong("slide"), help: "Slide number to render (1-based)")
    var slide: Int = 1
    
    @Option(name: .shortAndLong, help: "Output image file path")
    var output: String = "slide.png"
    
    @Option(name: .shortAndLong, help: "Image width in pixels")
    var width: Int = 1280
    
    @Option(name: .shortAndLong, help: "Image height in pixels")
    var height: Int = 720
    
    @Option(name: .shortAndLong, help: "Scale factor (1.0 or 2.0 for retina)")
    var scale: Double = 2.0
    
    mutating func run() throws {
        let fileURL = URL(fileURLWithPath: pptxPath)
        
        // Load the PPTX document
        let document = try PPTXDocument(filePath: fileURL.path)
        
        // Get slide count
        let slideCount = try document.getSlideCount()
        
        guard slide > 0 && slide <= slideCount else {
            throw ValidationError("Invalid slide number. Presentation has \(slideCount) slides.")
        }
        
        // Get the specific slide
        guard let slideToRender = try document.getSlide(at: slide) else {
            throw ValidationError("Could not load slide \(slide)")
        }
        
        print("Rendering slide \(slide) of \(slideCount)...")
        
        // Create rendering context
        let context = RenderingContext(
            size: CGSize(width: CGFloat(width), height: CGFloat(height)),
            scale: CGFloat(scale),
            quality: .high
        )
        
        let renderer = SlideRenderer(context: context, archive: document.archive)
        
        // Render the slide
        let cgImage = try renderer.render(slide: slideToRender)
        
        // Save to file
        let outputURL = URL(fileURLWithPath: output)
        
        if let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.png.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(destination, cgImage, nil)
            if CGImageDestinationFinalize(destination) {
                print("✅ Rendered slide saved to: \(outputURL.path)")
            } else {
                throw ValidationError("Failed to save image")
            }
        } else {
            throw ValidationError("Failed to create image destination")
        }
    }
}