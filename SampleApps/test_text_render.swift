#!/usr/bin/env swift

import Foundation
import PPTXKit
import CoreGraphics
import CoreText
import AppKit

// Test text rendering specifically
print("🔍 Testing text rendering...")

// Create a simple rendering context
let size = CGSize(width: 800, height: 600)
let context = RenderingContext(
    size: size,
    scale: 2.0,
    quality: .high
)

// Create graphics context
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

let pixelWidth = Int(size.width * 2.0)
let pixelHeight = Int(size.height * 2.0)

guard let cgContext = CGContext(
    data: nil,
    width: pixelWidth,
    height: pixelHeight,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: bitmapInfo
) else {
    print("❌ Failed to create context")
    exit(1)
}

// Apply scale
cgContext.scaleBy(x: 2.0, y: 2.0)

// Fill white background
cgContext.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
cgContext.fill(CGRect(origin: .zero, size: size))

// Test 1: Direct CoreText rendering
print("\n📝 Test 1: Direct CoreText rendering")

// Create simple text
let testString = "Hello PPTX World!"
let font = CTFontCreateWithName("Helvetica" as CFString, 36, nil)
let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: CGColor(red: 0, green: 0, blue: 0, alpha: 1)
]
let attributedString = NSAttributedString(string: testString, attributes: attributes)

// Create framesetter
let framesetter = CTFramesetterCreateWithAttributedString(attributedString)

// Create path
let textRect = CGRect(x: 50, y: 50, width: 700, height: 100)
let path = CGPath(rect: textRect, transform: nil)

// Create frame
let ctFrame = CTFramesetterCreateFrame(
    framesetter,
    CFRange(location: 0, length: attributedString.length),
    path,
    nil
)

// Draw frame
cgContext.saveGState()
cgContext.translateBy(x: 0, y: textRect.maxY)
cgContext.scaleBy(x: 1, y: -1)
cgContext.translateBy(x: 0, y: -textRect.minY)
CTFrameDraw(ctFrame, cgContext)
cgContext.restoreGState()

print("✅ Direct CoreText rendering complete")

// Test 2: Using TextRenderer
print("\n📝 Test 2: Using TextRenderer")

let textRenderer = TextRenderer(context: context)

// Create render element
let textStyle = TextStyle(
    font: NSFont.systemFont(ofSize: 24),
    color: CGColor(red: 0, green: 0, blue: 1, alpha: 1),
    alignment: .center
)

let element = RenderElement(
    type: .text,
    frame: CGRect(x: 50, y: 200, width: 700, height: 50),
    content: .text("Rendered with TextRenderer", textStyle)
)

do {
    try textRenderer.render(element, in: cgContext)
    print("✅ TextRenderer rendering complete")
} catch {
    print("❌ TextRenderer error: \(error)")
}

// Test 3: Check if text is visible
print("\n🔍 Checking rendered content...")

if let image = cgContext.makeImage() {
    let nsImage = NSImage(cgImage: image, size: size)
    
    if let tiffData = nsImage.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData) {
        
        // Sample pixels to check for non-white content
        var hasBlackText = false
        var hasBlueText = false
        
        for x in stride(from: 0, to: Int(bitmap.pixelsWide), by: 50) {
            for y in stride(from: 0, to: Int(bitmap.pixelsHigh), by: 50) {
                if let color = bitmap.colorAt(x: x, y: y) {
                    // Check for black text
                    if color.redComponent < 0.1 && color.greenComponent < 0.1 && color.blueComponent < 0.1 {
                        hasBlackText = true
                    }
                    // Check for blue text
                    if color.blueComponent > 0.8 && color.redComponent < 0.2 && color.greenComponent < 0.2 {
                        hasBlueText = true
                    }
                }
            }
        }
        
        print("   - Has black text: \(hasBlackText)")
        print("   - Has blue text: \(hasBlueText)")
        
        // Save image
        if let pngData = bitmap.representation(using: .png, properties: [:]) {
            let outputPath = "/tmp/test_text_render.png"
            try? pngData.write(to: URL(fileURLWithPath: outputPath))
            print("   - Saved to: \(outputPath)")
            
            // Open the image
            Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [outputPath])
        }
    }
}

print("\n✅ Test complete")