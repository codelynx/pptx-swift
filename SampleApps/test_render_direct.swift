#!/usr/bin/env swift

import Foundation
import PPTXKit
import CoreGraphics
import AppKit

// Test direct rendering
let filePath = "/Users/kyoshikawa/prj/pptx-swift/samples/sample1_SSI_Chap2.pptx"

do {
    print("🔍 Testing direct rendering...")
    
    // Load document and get first slide
    let doc = try PPTXDocument(filePath: filePath)
    guard let slide = try doc.getSlide(at: 1) else {
        print("❌ No slide found")
        exit(1)
    }
    
    print("✅ Loaded slide:")
    print("   - Title: \(slide.title ?? "No title")")
    print("   - Text content: \(slide.textContent)")
    print("   - Shape count: \(slide.shapeCount)")
    
    // Create rendering context
    let size = CGSize(width: 800, height: 600)
    let context = RenderingContext(
        size: size,
        scale: 2.0,
        quality: .high
    )
    
    print("\n🎨 Creating renderer...")
    let renderer = SlideRenderer(context: context)
    
    print("🖼️ Rendering slide...")
    let cgImage = try renderer.render(slide: slide)
    
    print("✅ Rendered successfully!")
    print("   - Image size: \(cgImage.width) x \(cgImage.height)")
    
    // Check if image has content
    let nsImage = NSImage(cgImage: cgImage, size: size)
    if let tiffData = nsImage.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData) {
        
        // Sample some pixels to see if it's not all white
        var hasContent = false
        for x in stride(from: 0, to: Int(bitmap.pixelsWide), by: 100) {
            for y in stride(from: 0, to: Int(bitmap.pixelsHigh), by: 100) {
                if let color = bitmap.colorAt(x: x, y: y) {
                    // Check if pixel is not white
                    if color.redComponent < 0.99 || color.greenComponent < 0.99 || color.blueComponent < 0.99 {
                        hasContent = true
                        break
                    }
                }
            }
            if hasContent { break }
        }
        
        print("   - Has visible content: \(hasContent)")
        
        // Save the image for inspection
        if let pngData = bitmap.representation(using: .png, properties: [:]) {
            let outputPath = "/tmp/test_direct_render.png"
            try pngData.write(to: URL(fileURLWithPath: outputPath))
            print("   - Saved to: \(outputPath)")
            
            // Open the image
            Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [outputPath])
        }
    }
    
} catch {
    print("❌ Error: \(error)")
    print("   Type: \(type(of: error))")
}