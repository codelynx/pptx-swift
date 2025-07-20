#!/usr/bin/env swift

import Foundation
import CoreGraphics
import AppKit

// Simple test to check the full pipeline from loading to rendering

print("Testing Full PPTX Pipeline")
print("==========================\n")

// Mock classes to simulate the pipeline
struct MockSlide {
    let id: String
    let index: Int
    let title: String?
    let textContent: [String]
}

class MockSlideRenderer {
    func render(slide: MockSlide, size: CGSize) -> CGImage? {
        print("Attempting to render slide \(slide.index):")
        print("  Title: \(slide.title ?? "No title")")
        print("  Text content: \(slide.textContent)")
        
        // Create a simple test image
        let scale: CGFloat = 2.0
        let pixelWidth = Int(size.width * scale)
        let pixelHeight = Int(size.height * scale)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            print("  ❌ Failed to create context")
            return nil
        }
        
        // Scale for retina
        context.scaleBy(x: scale, y: scale)
        
        // Draw white background
        context.setFillColor(NSColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw some content based on what's in the slide
        if slide.title != nil || !slide.textContent.isEmpty {
            // Has content - draw blue rectangle
            context.setFillColor(NSColor.blue.cgColor)
            context.fill(CGRect(x: 50, y: 50, width: size.width - 100, height: 100))
            print("  ✅ Drew content (blue rectangle)")
        } else {
            // No content - draw red rectangle
            context.setFillColor(NSColor.red.cgColor)
            context.fill(CGRect(x: 50, y: 50, width: size.width - 100, height: 100))
            print("  ⚠️  No content to render (red rectangle)")
        }
        
        // Create image
        if let image = context.makeImage() {
            print("  ✅ Created CGImage successfully")
            return image
        } else {
            print("  ❌ Failed to create CGImage")
            return nil
        }
    }
}

// Test the rendering pipeline
print("1. Creating test slides...")
let testSlides = [
    MockSlide(id: "slide1", index: 1, title: "Title Slide", textContent: ["Welcome to the presentation"]),
    MockSlide(id: "slide2", index: 2, title: nil, textContent: ["Content without title"]),
    MockSlide(id: "slide3", index: 3, title: "Empty Slide", textContent: [])
]

print("\n2. Testing rendering for each slide...")
let renderer = MockSlideRenderer()
let testSize = CGSize(width: 800, height: 600)

for slide in testSlides {
    print("\n---")
    if let image = renderer.render(slide: slide, size: testSize) {
        print("Final result: ✅ Slide \(slide.index) rendered successfully")
        print("Image size: \(image.width) x \(image.height) pixels")
    } else {
        print("Final result: ❌ Slide \(slide.index) failed to render")
    }
}

// Test what happens with empty slide data
print("\n\n3. Testing with empty slide data...")
let emptySlide = MockSlide(id: "empty", index: 4, title: nil, textContent: [])
if let image = renderer.render(slide: emptySlide, size: testSize) {
    print("Empty slide rendered: ✅")
} else {
    print("Empty slide failed: ❌")
}

// Check if the issue might be with slide content extraction
print("\n\n4. Potential issues to investigate:")
print("- Are slides being loaded with actual content from the XML?")
print("- Is the XML parser correctly extracting text from slides?")
print("- Is the SlideRenderer receiving slides with empty content?")
print("- Is there an issue with the SwiftUI/AppKit view update cycle?")

print("\n✅ Pipeline test complete!")