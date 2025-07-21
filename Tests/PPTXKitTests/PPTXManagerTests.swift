import XCTest
@testable import PPTXKit

final class PPTXManagerTests: XCTestCase {
	
	var manager: PPTXManager!
	
	override func setUp() {
		super.setUp()
		manager = PPTXManager()
	}
	
	override func tearDown() {
		manager = nil
		super.tearDown()
	}
	
	// MARK: - Initialization Tests
	
	func testInitialization() {
		XCTAssertEqual(manager.currentSlideIndex, 1)
		XCTAssertEqual(manager.slideCount, 0)
		XCTAssertNil(manager.currentSlide)
		XCTAssertFalse(manager.isLoading)
		XCTAssertNil(manager.error)
	}
	
	// MARK: - Navigation Tests
	
	func testNavigationWithoutPresentation() {
		// Should not be able to navigate without a loaded presentation
		XCTAssertFalse(manager.canGoPrevious)
		XCTAssertFalse(manager.canGoNext)
		XCTAssertFalse(manager.goToNext())
		XCTAssertFalse(manager.goToPrevious())
		XCTAssertFalse(manager.goToSlide(at: 5))
	}
	
	func testNavigationWithMockSlides() {
		// Without access to inject mock slides directly (private property),
		// we can only test the initial state
		XCTAssertEqual(manager.currentSlideIndex, 1)
		XCTAssertEqual(manager.slideCount, 0)
		
		// Navigation should fail without loaded slides
		XCTAssertFalse(manager.goToNext())
		XCTAssertFalse(manager.goToPrevious())
	}
	
	func testProgress() {
		// Without slides
		XCTAssertEqual(manager.progress, 0.0)
		
		// We would need to load a presentation to test this properly
	}
	
	// MARK: - Search Tests
	
	func testSearchWithNoSlides() {
		let results = manager.searchSlides(containing: "test")
		XCTAssertTrue(results.isEmpty)
	}
	
	// MARK: - Delegate Tests
	
	func testDelegatePattern() {
		class MockDelegate: PPTXManagerDelegate {
			var didLoadPresentationCalled = false
			var didNavigateCalled = false
			var didEncounterErrorCalled = false
			var slideCount = 0
			var fromIndex = 0
			var toIndex = 0
			
			func pptxManager(_ manager: PPTXManager, didLoadPresentationWithSlideCount count: Int) {
				didLoadPresentationCalled = true
				slideCount = count
			}
			
			func pptxManager(_ manager: PPTXManager, didNavigateFrom oldIndex: Int, to newIndex: Int) {
				didNavigateCalled = true
				fromIndex = oldIndex
				toIndex = newIndex
			}
			
			func pptxManager(_ manager: PPTXManager, didEncounterError error: Error) {
				didEncounterErrorCalled = true
			}
		}
		
		let mockDelegate = MockDelegate()
		manager.delegate = mockDelegate
		
		// Test that delegate is properly set
		XCTAssertNotNil(manager.delegate)
	}
	
	// MARK: - Command Tests
	
	func testNavigationCommands() {
		// Test command execution without slides
		XCTAssertFalse(manager.execute(.next))
		XCTAssertFalse(manager.execute(.previous))
		XCTAssertFalse(manager.execute(.first)) // Fails with no slides
		XCTAssertFalse(manager.execute(.last)) // Fails with no slides
		XCTAssertFalse(manager.execute(.goTo(index: 5)))
	}
	
	// MARK: - View Creation Tests
	
	func testCreateSlideViewWithoutPresentation() {
		XCTAssertNil(manager.createSlideView())
		XCTAssertNil(manager.createSlideView(for: 1))
	}
	
	func testSlideAccess() {
		XCTAssertNil(manager.slide(at: 1))
		XCTAssertNil(manager.slide(withId: "slide1"))
		XCTAssertTrue(manager.allSlides().isEmpty)
	}
}

// MARK: - Integration Tests

final class PPTXManagerIntegrationTests: XCTestCase {
	
	func testLoadingNonExistentFile() throws {
		let manager = PPTXManager()
		
		do {
			try manager.loadPresentation(from: "/non/existent/file.pptx")
			XCTFail("Expected error to be thrown")
		} catch {
			// Expected error
			XCTAssertNotNil(error)
		}
		
		XCTAssertNotNil(manager.error)
		XCTAssertEqual(manager.slideCount, 0)
	}
	
	func testManagerWithRealFile() throws {
		// This would require a test PPTX file in the test bundle
		guard let url = Bundle.module.url(forResource: "test", withExtension: "pptx") else {
			throw XCTSkip("No test PPTX file available")
		}
		
		let manager = try PPTXManager(filePath: url.path)
		
		XCTAssertGreaterThan(manager.slideCount, 0)
		XCTAssertNotNil(manager.currentSlide)
		XCTAssertNotNil(manager.metadata)
		
		// Test navigation
		if manager.slideCount > 1 {
			XCTAssertTrue(manager.goToNext())
			XCTAssertEqual(manager.currentSlideIndex, 2)
			
			XCTAssertTrue(manager.goToPrevious())
			XCTAssertEqual(manager.currentSlideIndex, 1)
			
			XCTAssertTrue(manager.goToLast())
			XCTAssertEqual(manager.currentSlideIndex, manager.slideCount)
			
			XCTAssertTrue(manager.goToFirst())
			XCTAssertEqual(manager.currentSlideIndex, 1)
		}
	}
}