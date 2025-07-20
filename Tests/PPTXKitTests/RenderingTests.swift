import XCTest
@testable import PPTXKit
import CoreGraphics

final class RenderingTests: XCTestCase {
    
    func testRenderingContextCreation() {
        let context = RenderingContext(
            size: CGSize(width: 800, height: 600),
            scale: 2.0,
            quality: .high
        )
        
        XCTAssertEqual(context.size.width, 800)
        XCTAssertEqual(context.size.height, 600)
        XCTAssertEqual(context.scale, 2.0)
        XCTAssertEqual(context.quality, .high)
    }
    
    func testEMUConversion() {
        let context = RenderingContext(size: CGSize(width: 800, height: 600))
        
        // Test EMU to points conversion
        // 1 point = 12,700 EMUs
        let emus = 127000
        let points = context.emuToPoints(emus)
        XCTAssertEqual(points, 10.0, accuracy: 0.01)
        
        // Test EMU to pixels conversion with scale
        let context2 = RenderingContext(size: CGSize(width: 800, height: 600), scale: 2.0)
        let pixels = context2.emuToPixels(emus)
        XCTAssertEqual(pixels, 20.0, accuracy: 0.01)
    }
    
    func testSlideRenderer() throws {
        // Create a mock slide
        let slide = Slide(
            id: "slide1",
            index: 1,
            layoutType: "Title Slide",
            title: "Test Slide",
            shapeCount: 2,
            notes: nil,
            relationships: [],
            textContent: ["Hello", "World"]
        )
        
        // Create rendering context
        let context = RenderingContext(
            size: CGSize(width: 400, height: 300),
            scale: 1.0,
            quality: .balanced
        )
        
        // Create renderer
        let renderer = SlideRenderer(context: context)
        
        // Render slide
        let image = try renderer.render(slide: slide)
        
        // Verify image was created
        XCTAssertGreaterThan(image.width, 0)
        XCTAssertGreaterThan(image.height, 0)
        XCTAssertEqual(image.width, 400)
        XCTAssertEqual(image.height, 300)
    }
    
    func testShapeRendering() {
        let context = RenderingContext(size: CGSize(width: 100, height: 100))
        _ = ShapeRenderer(context: context)
        
        // Test arrow path creation
        let arrowPath = ShapeRenderer.createArrowPath(in: CGRect(x: 0, y: 0, width: 100, height: 50))
        let arrowBounds = arrowPath.boundingBox
        XCTAssertEqual(arrowBounds.width, 100, accuracy: 0.1)
        XCTAssertEqual(arrowBounds.height, 50, accuracy: 0.1)
        
        // Test star path creation
        let starPath = ShapeRenderer.createStarPath(points: 5, in: CGRect(x: 0, y: 0, width: 100, height: 100))
        let starBounds = starPath.boundingBox
        // Star paths have inner points, so bounds are slightly smaller than the rect
        XCTAssertEqual(starBounds.width, 100, accuracy: 10.0)
        XCTAssertEqual(starBounds.height, 100, accuracy: 10.0)
    }
    
    func testFontMapping() {
        let fontMapper = FontMapper()
        
        // Test common font mappings
        XCTAssertEqual(fontMapper.mapFontName("Calibri"), "Helvetica Neue")
        XCTAssertEqual(fontMapper.mapFontName("Arial"), "Helvetica")
        XCTAssertEqual(fontMapper.mapFontName("Times New Roman"), "Times")
        XCTAssertEqual(fontMapper.mapFontName("Comic Sans MS"), "Marker Felt")
        
        // Test unknown font (should return original)
        XCTAssertEqual(fontMapper.mapFontName("Unknown Font"), "Unknown Font")
    }
    
    func testRenderingQuality() {
        // Test quality settings
        XCTAssertFalse(RenderingQuality.low.rendersGradients)
        XCTAssertTrue(RenderingQuality.balanced.rendersGradients)
        XCTAssertTrue(RenderingQuality.high.rendersGradients)
        
        XCTAssertFalse(RenderingQuality.low.rendersShadows)
        XCTAssertTrue(RenderingQuality.balanced.rendersShadows)
        XCTAssertTrue(RenderingQuality.high.rendersShadows)
    }
    
    func testRenderElementCreation() {
        // Test shape element
        let shapeData = ShapeData(
            type: .rectangle,
            fill: .solid(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        )
        let shapeElement = RenderElement(
            type: .shape,
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            content: .shape(shapeData)
        )
        
        XCTAssertEqual(shapeElement.type, .shape)
        XCTAssertEqual(shapeElement.frame.width, 100)
        
        // Test text element
        let textElement = RenderElement(
            type: .text,
            frame: CGRect(x: 0, y: 0, width: 200, height: 50),
            content: .text("Hello", TextStyle.body)
        )
        
        XCTAssertEqual(textElement.type, .text)
        if case .text(let text, _) = textElement.content {
            XCTAssertEqual(text, "Hello")
        } else {
            XCTFail("Expected text content")
        }
    }
    
    func testSlideViewInitialization() {
        let slide = Slide(
            id: "test",
            index: 1,
            layoutType: nil,
            title: "Test",
            shapeCount: 0,
            notes: nil,
            relationships: [],
            textContent: []
        )
        
        #if canImport(UIKit)
        let view = PPTXSlideView(slide: slide, frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertNotNil(view)
        XCTAssertEqual(view.frame.width, 100)
        #elseif canImport(AppKit)
        let view = PPTXSlideView(slide: slide, frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertNotNil(view)
        XCTAssertEqual(view.frame.width, 100)
        #endif
    }
}

// MARK: - Performance Tests

extension RenderingTests {
    func testRenderingPerformance() throws {
        let slide = Slide(
            id: "perf-test",
            index: 1,
            layoutType: "Complex",
            title: "Performance Test",
            shapeCount: 20,
            notes: nil,
            relationships: [],
            textContent: Array(repeating: "Text content line", count: 10)
        )
        
        let context = RenderingContext(
            size: CGSize(width: 1920, height: 1080),
            scale: 2.0,
            quality: .high
        )
        
        let renderer = SlideRenderer(context: context)
        
        measure {
            _ = try? renderer.render(slide: slide)
        }
    }
}