import Foundation
import CoreGraphics

/// High-level manager for PPTX presentations providing navigation and view management
public class PPTXManager: ObservableObject {
    
    // MARK: - Properties
    
    /// The loaded PPTX document
    public private(set) var document: PPTXDocument?
    
    /// All slides in the presentation
    private var slides: [Slide] = []
    
    /// Current slide index (1-based)
    @Published public private(set) var currentSlideIndex: Int = 1
    
    /// Total number of slides
    @Published public private(set) var slideCount: Int = 0
    
    /// Presentation metadata
    @Published public private(set) var metadata: PresentationMetadata?
    
    /// Loading state
    @Published public private(set) var isLoading: Bool = false
    
    /// Error state
    @Published public private(set) var error: Error?
    
    /// Navigation delegate
    public weak var delegate: PPTXManagerDelegate?
    
    // MARK: - Computed Properties
    
    /// Current slide
    public var currentSlide: Slide? {
        guard currentSlideIndex > 0 && currentSlideIndex <= slides.count else { return nil }
        return slides[currentSlideIndex - 1]
    }
    
    /// Can navigate to previous slide
    public var canGoPrevious: Bool {
        return currentSlideIndex > 1
    }
    
    /// Can navigate to next slide
    public var canGoNext: Bool {
        return currentSlideIndex < slideCount
    }
    
    /// Progress through presentation (0.0 to 1.0)
    public var progress: Double {
        guard slideCount > 0 else { return 0 }
        return Double(currentSlideIndex) / Double(slideCount)
    }
    
    // MARK: - Initialization
    
    public init() {}
    
    /// Initialize with a PPTX file path
    public convenience init(filePath: String) throws {
        self.init()
        try loadPresentation(from: filePath)
    }
    
    // MARK: - Loading
    
    /// Load a PPTX presentation from file path
    public func loadPresentation(from filePath: String) throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // Load document
            let doc = try PPTXDocument(filePath: filePath)
            self.document = doc
            
            // Load slides with full details
            let basicSlides = try doc.getSlides()
            self.slides = []
            
            // Load full details for each slide
            for (index, _) in basicSlides.enumerated() {
                if let detailedSlide = try doc.getSlide(at: index + 1) {
                    self.slides.append(detailedSlide)
                }
            }
            
            self.slideCount = slides.count
            
            // Load metadata
            self.metadata = try doc.getMetadata()
            
            // Reset to first slide
            if slideCount > 0 {
                currentSlideIndex = 1
                delegate?.pptxManager(self, didLoadPresentationWithSlideCount: slideCount)
            }
            
        } catch {
            self.error = error
            self.document = nil
            self.slides = []
            self.slideCount = 0
            self.currentSlideIndex = 1
            throw error
        }
    }
    
    // MARK: - Navigation
    
    /// Go to the previous slide
    @discardableResult
    public func goToPrevious() -> Bool {
        guard canGoPrevious else { return false }
        
        let newIndex = currentSlideIndex - 1
        return goToSlide(at: newIndex)
    }
    
    /// Go to the next slide
    @discardableResult
    public func goToNext() -> Bool {
        guard canGoNext else { return false }
        
        let newIndex = currentSlideIndex + 1
        return goToSlide(at: newIndex)
    }
    
    /// Go to a specific slide by index (1-based)
    @discardableResult
    public func goToSlide(at index: Int) -> Bool {
        guard index > 0 && index <= slideCount else { return false }
        
        let oldIndex = currentSlideIndex
        currentSlideIndex = index
        
        delegate?.pptxManager(self, didNavigateFrom: oldIndex, to: index)
        
        return true
    }
    
    /// Go to a specific slide by ID
    @discardableResult
    public func goToSlide(withId slideId: String) -> Bool {
        guard let index = slides.firstIndex(where: { $0.id == slideId }) else { return false }
        return goToSlide(at: index + 1)
    }
    
    /// Go to the first slide
    @discardableResult
    public func goToFirst() -> Bool {
        return goToSlide(at: 1)
    }
    
    /// Go to the last slide
    @discardableResult
    public func goToLast() -> Bool {
        return goToSlide(at: slideCount)
    }
    
    // MARK: - Slide Access
    
    /// Get slide at specific index (1-based)
    public func slide(at index: Int) -> Slide? {
        guard index > 0 && index <= slides.count else { return nil }
        return slides[index - 1]
    }
    
    /// Get slide with specific ID
    public func slide(withId slideId: String) -> Slide? {
        return slides.first { $0.id == slideId }
    }
    
    /// Get all slides
    public func allSlides() -> [Slide] {
        return slides
    }
    
    // MARK: - Search
    
    /// Search for slides containing text
    public func searchSlides(containing text: String) -> [Slide] {
        let searchText = text.lowercased()
        return slides.filter { slide in
            // Search in title
            if let title = slide.title?.lowercased(), title.contains(searchText) {
                return true
            }
            // Search in text content
            return slide.textContent.contains { $0.lowercased().contains(searchText) }
        }
    }
    
    // MARK: - Export
    
    /// Create a view for the current slide
    public func createSlideView(frame: CGRect = .zero) -> PPTXSlideView? {
        guard let slide = currentSlide else { return nil }
        return PPTXSlideView(slide: slide, frame: frame)
    }
    
    /// Create a view for a specific slide
    public func createSlideView(for slideIndex: Int, frame: CGRect = .zero) -> PPTXSlideView? {
        guard let slide = slide(at: slideIndex) else { return nil }
        return PPTXSlideView(slide: slide, frame: frame)
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for PPTXManager events
public protocol PPTXManagerDelegate: AnyObject {
    /// Called when a presentation is loaded
    func pptxManager(_ manager: PPTXManager, didLoadPresentationWithSlideCount count: Int)
    
    /// Called when navigation occurs
    func pptxManager(_ manager: PPTXManager, didNavigateFrom oldIndex: Int, to newIndex: Int)
    
    /// Called when an error occurs
    func pptxManager(_ manager: PPTXManager, didEncounterError error: Error)
}

// MARK: - Navigation Commands

extension PPTXManager {
    /// Keyboard navigation support
    public enum NavigationCommand {
        case next
        case previous
        case first
        case last
        case goTo(index: Int)
    }
    
    /// Execute a navigation command
    @discardableResult
    public func execute(_ command: NavigationCommand) -> Bool {
        switch command {
        case .next:
            return goToNext()
        case .previous:
            return goToPrevious()
        case .first:
            return goToFirst()
        case .last:
            return goToLast()
        case .goTo(let index):
            return goToSlide(at: index)
        }
    }
}