#!/usr/bin/env swift

import Foundation
import PPTXKit

// Test slide loading issue
let filePath = "/Users/kyoshikawa/prj/pptx-swift/samples/sample1_SSI_Chap2.pptx"

print("🔍 Testing slide loading...")

// Test 1: Direct document loading
do {
    let doc = try PPTXDocument(filePath: filePath)
    print("✅ Document loaded")
    
    // Get slides basic info
    let slides = try doc.getSlides()
    print("📊 Basic slides: \(slides.count)")
    for (i, slide) in slides.enumerated() {
        print("   Slide \(i+1): \(slide.id)")
    }
    
    // Get first slide with details
    if let firstSlide = try doc.getSlide(at: 1) {
        print("\n✅ First slide details:")
        print("   - ID: \(firstSlide.id)")
        print("   - Index: \(firstSlide.index)")
        print("   - Title: \(firstSlide.title ?? "No title")")
        print("   - Text content: \(firstSlide.textContent)")
        print("   - Shape count: \(firstSlide.shapeCount)")
    }
} catch {
    print("❌ Document error: \(error)")
}

print("\n" + String(repeating: "-", count: 50) + "\n")

// Test 2: PPTXManager loading
do {
    let manager = PPTXManager()
    try manager.loadPresentation(from: filePath)
    
    print("✅ Manager loaded")
    print("📊 Manager slides: \(manager.slideCount)")
    print("📍 Current slide index: \(manager.currentSlideIndex)")
    
    // Check current slide
    if let currentSlide = manager.currentSlide {
        print("\n✅ Current slide from manager:")
        print("   - ID: \(currentSlide.id)")
        print("   - Index: \(currentSlide.index)")
        print("   - Title: \(currentSlide.title ?? "No title")")
        print("   - Text content count: \(currentSlide.textContent.count)")
        print("   - Shape count: \(currentSlide.shapeCount)")
    } else {
        print("❌ manager.currentSlide is nil!")
    }
    
    // Test all slides
    print("\n📑 All slides from manager:")
    for (i, slide) in manager.allSlides().enumerated() {
        print("   Slide \(i+1):")
        print("     - ID: \(slide.id)")
        print("     - Title: \(slide.title ?? "No title")")
        print("     - Has content: \(!slide.textContent.isEmpty)")
    }
    
} catch {
    print("❌ Manager error: \(error)")
}