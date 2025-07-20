#!/usr/bin/env swift

import Foundation
import PPTXKit
import CoreGraphics
import AppKit

// Test rendering a slide
do {
    print("🔍 Testing PPTX rendering on macOS...")
    
    // Create a simple test PPTX for verification
    print("📄 Using user's PPTX file (you'll need to select one)...")
    
    // For now, let's test with a hardcoded path - replace with your own PPTX file
    let testFile = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/path/to/your/test.pptx"
    
    guard FileManager.default.fileExists(atPath: testFile) else {
        print("❌ Please provide a PPTX file path as argument")
        print("Usage: swift run TestRendering /path/to/your/file.pptx")
        exit(1)
    }
    let doc = try PPTXDocument(filePath: testFile)
    
    print("✅ Loaded document")
    
    // Get first slide with full details
    guard let slide = try doc.getSlide(at: 1) else {
        print("❌ No slide found")
        exit(1)
    }
    
    print("✅ Loaded slide:")
    print("   Title: \(slide.title ?? "No title")")
    print("   Text content: \(slide.textContent.count) items")
    print("   Shape count: \(slide.shapeCount)")
    
    // Create rendering context
    let size = CGSize(width: 800, height: 600)
    let context = RenderingContext(
        size: size,
        scale: 2.0,
        quality: .high
    )
    
    // Create renderer
    let renderer = SlideRenderer(context: context)
    
    // Render slide
    print("🎨 Rendering slide...")
    let cgImage = try renderer.render(slide: slide)
    
    // Convert to NSImage
    let nsImage = NSImage(cgImage: cgImage, size: size)
    
    print("✅ Rendered successfully!")
    print("   Image size: \(nsImage.size)")
    
    // Save to file for verification
    let outputPath = "/tmp/test_slide_render.png"
    if let tiffData = nsImage.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Saved rendered image to: \(outputPath)")
        
        // Open the image
        Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [outputPath])
    }
    
} catch {
    print("❌ Error: \(error)")
    exit(1)
}