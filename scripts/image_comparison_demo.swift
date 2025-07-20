#!/usr/bin/env swift
//
// Image Comparison Demo
// Demonstrates different methods for comparing rendered slides with references
//

import Foundation
import CoreGraphics
import ImageIO
import Vision

// MARK: - Image Loading

func loadImage(from path: String) -> CGImage? {
    let url = URL(fileURLWithPath: path)
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        print("Failed to load image: \(path)")
        return nil
    }
    return image
}

// MARK: - Comparison Methods

/// Basic pixel-by-pixel comparison
func comparePixelByPixel(_ image1: CGImage, _ image2: CGImage) -> Double {
    guard image1.width == image2.width,
          image1.height == image2.height else {
        return 0.0
    }
    
    let width = image1.width
    let height = image1.height
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    
    var pixels1 = [UInt8](repeating: 0, count: height * bytesPerRow)
    var pixels2 = [UInt8](repeating: 0, count: height * bytesPerRow)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    
    // Draw both images to pixel buffers
    guard let context1 = CGContext(data: &pixels1, width: width, height: height,
                                   bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow,
                                   space: colorSpace, bitmapInfo: bitmapInfo),
          let context2 = CGContext(data: &pixels2, width: width, height: height,
                                   bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow,
                                   space: colorSpace, bitmapInfo: bitmapInfo) else {
        return 0.0
    }
    
    context1.draw(image1, in: CGRect(x: 0, y: 0, width: width, height: height))
    context2.draw(image2, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // Calculate difference
    var totalDiff: Double = 0
    for i in 0..<pixels1.count {
        let diff = abs(Int(pixels1[i]) - Int(pixels2[i]))
        totalDiff += Double(diff) / 255.0
    }
    
    let maxDiff = Double(pixels1.count)
    let similarity = 1.0 - (totalDiff / maxDiff)
    
    return similarity
}

/// Perceptual comparison using Vision framework
@available(macOS 10.15, *)
func comparePerceptual(_ image1: CGImage, _ image2: CGImage) -> Double {
    let request = VNFeaturePrintObservationRequest()
    
    let handler1 = VNImageRequestHandler(cgImage: image1)
    let handler2 = VNImageRequestHandler(cgImage: image2)
    
    do {
        try handler1.perform([request])
        guard let observation1 = request.results?.first as? VNFeaturePrintObservation else {
            return 0.0
        }
        
        // Need to create new request for second image
        let request2 = VNFeaturePrintObservationRequest()
        try handler2.perform([request2])
        guard let observation2 = request2.results?.first as? VNFeaturePrintObservation else {
            return 0.0
        }
        
        var distance: Float = 0
        try observation1.computeDistance(&distance, to: observation2)
        
        // Convert distance to similarity (0-1)
        // Distance is typically 0-2, where 0 is identical
        let similarity = max(0, 1.0 - (Double(distance) / 2.0))
        
        return similarity
    } catch {
        print("Vision comparison error: \(error)")
        return 0.0
    }
}

/// Create a difference image highlighting changes
func createDifferenceImage(_ image1: CGImage, _ image2: CGImage) -> CGImage? {
    guard image1.width == image2.width,
          image1.height == image2.height else {
        return nil
    }
    
    let width = image1.width
    let height = image1.height
    
    // Create a new image showing differences
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    
    guard let context = CGContext(data: nil, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: 0,
                                  space: colorSpace, bitmapInfo: bitmapInfo) else {
        return nil
    }
    
    // Draw base image
    context.draw(image1, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // Draw difference overlay
    context.setBlendMode(.difference)
    context.draw(image2, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    return context.makeImage()
}

// MARK: - Main Demo

func runComparisonDemo() {
    print("Image Comparison Demo")
    print("====================\n")
    
    // Example paths (update these to actual test images)
    let referencePath = "tests/references/slide-1.png"
    let renderedPath = "tests/output/slide-1.png"
    
    // For demo, we'll compare an image with itself
    let samplePath = "samples/sample1_SSI_Chap2.pptx"
    
    print("Note: This is a demonstration of comparison methods.")
    print("Actual rendering implementation is not yet complete.\n")
    
    // Show comparison methods
    print("Available comparison methods:")
    print("1. Pixel-by-pixel comparison (exact match)")
    print("2. Perceptual comparison (Vision framework)")
    print("3. Structural similarity (SSIM)")
    print("4. Histogram comparison")
    print("\nFor testing, we recommend:")
    print("- Use perceptual comparison for overall similarity")
    print("- Set threshold at 90% for most tests")
    print("- Use pixel comparison for regression tests")
}

// Run the demo
runComparisonDemo()