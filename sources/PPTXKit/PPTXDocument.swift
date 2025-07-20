import Foundation
import ZIPFoundation

/// Represents a PowerPoint (PPTX) document
public class PPTXDocument {
    /// Path to the PPTX file
    public let filePath: URL
    
    /// Archive containing the PPTX contents
    private var archive: Archive?
    
    /// Errors that can occur when working with PPTX files
    public enum PPTXError: Error, LocalizedError {
        case fileNotFound
        case invalidPPTXFile
        case corruptedArchive
        case missingRequiredFile(String)
        case invalidXML(String)
        
        public var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "PPTX file not found"
            case .invalidPPTXFile:
                return "Invalid PPTX file format"
            case .corruptedArchive:
                return "Corrupted PPTX archive"
            case .missingRequiredFile(let file):
                return "Missing required file: \(file)"
            case .invalidXML(let file):
                return "Invalid XML in file: \(file)"
            }
        }
    }
    
    /// Initialize with a file path
    public init(filePath: String) throws {
        self.filePath = URL(fileURLWithPath: filePath)
        
        // Verify file exists
        guard FileManager.default.fileExists(atPath: self.filePath.path) else {
            throw PPTXError.fileNotFound
        }
        
        // Try to open as ZIP archive
        guard let archive = Archive(url: self.filePath, accessMode: .read) else {
            throw PPTXError.invalidPPTXFile
        }
        
        self.archive = archive
        
        // Validate basic PPTX structure
        try validatePPTXStructure()
    }
    
    /// Validate that this is a valid PPTX file
    private func validatePPTXStructure() throws {
        guard let archive = self.archive else {
            throw PPTXError.corruptedArchive
        }
        
        // Check for required files in PPTX structure
        let requiredFiles = [
            "[Content_Types].xml",
            "_rels/.rels",
            "ppt/presentation.xml"
        ]
        
        for requiredFile in requiredFiles {
            guard archive[requiredFile] != nil else {
                throw PPTXError.missingRequiredFile(requiredFile)
            }
        }
    }
    
    /// Get the total number of slides
    public func getSlideCount() throws -> Int {
        guard let archive = self.archive else {
            throw PPTXError.corruptedArchive
        }
        
        // Read presentation.xml
        guard let entry = archive["ppt/presentation.xml"] else {
            throw PPTXError.missingRequiredFile("ppt/presentation.xml")
        }
        
        var presentationData = Data()
        do {
            _ = try archive.extract(entry) { data in
                presentationData.append(data)
            }
        } catch {
            throw PPTXError.corruptedArchive
        }
        
        // Parse XML to count slides
        let parser = PPTXXMLParser()
        return try parser.extractSlideCount(from: presentationData)
    }
    
    /// Get list of all slides
    public func getSlides() throws -> [Slide] {
        guard let archive = self.archive else {
            throw PPTXError.corruptedArchive
        }
        
        // Read presentation.xml
        guard let presentationEntry = archive["ppt/presentation.xml"] else {
            throw PPTXError.missingRequiredFile("ppt/presentation.xml")
        }
        
        var presentationData = Data()
        do {
            _ = try archive.extract(presentationEntry) { data in
                presentationData.append(data)
            }
        } catch {
            throw PPTXError.corruptedArchive
        }
        
        // Read relationships
        guard let relsEntry = archive["ppt/_rels/presentation.xml.rels"] else {
            throw PPTXError.missingRequiredFile("ppt/_rels/presentation.xml.rels")
        }
        
        var relsData = Data()
        do {
            _ = try archive.extract(relsEntry) { data in
                relsData.append(data)
            }
        } catch {
            throw PPTXError.corruptedArchive
        }
        
        // Parse XMLs
        let parser = PPTXXMLParser()
        let slideInfos = try parser.parsePresentation(data: presentationData)
        let relationships = try parser.parseRelationships(data: relsData)
        
        // Build slide list
        var slides: [Slide] = []
        
        for (index, slideInfo) in slideInfos.enumerated() {
            let slideIndex = index + 1 // 1-based
            
            // Get slide file name from relationship
            guard let slidePath = relationships[slideInfo.rId] else {
                continue
            }
            
            // Extract slide ID from path (e.g., "slides/slide1.xml" -> "slide1")
            let slideId = slidePath
                .replacingOccurrences(of: "slides/", with: "")
                .replacingOccurrences(of: ".xml", with: "")
            
            let slide = Slide(
                id: slideId,
                index: slideIndex,
                layoutType: nil, // Will be populated when we parse individual slides
                title: nil       // Will be populated when we parse individual slides
            )
            
            slides.append(slide)
        }
        
        return slides
    }
    
    /// Get a specific slide by index (1-based)
    public func getSlide(at index: Int) throws -> Slide? {
        let slides = try getSlides()
        
        guard index > 0 && index <= slides.count else {
            return nil
        }
        
        let slide = slides[index - 1]
        return try loadSlideDetails(slide)
    }
    
    /// Get a specific slide by ID
    public func getSlide(withId id: String) throws -> Slide? {
        let slides = try getSlides()
        
        guard let slide = slides.first(where: { $0.id == id }) else {
            return nil
        }
        
        return try loadSlideDetails(slide)
    }
    
    /// Load detailed information for a slide
    private func loadSlideDetails(_ slide: Slide) throws -> Slide {
        guard let archive = self.archive else {
            throw PPTXError.corruptedArchive
        }
        
        let slidePath = "ppt/slides/\(slide.id).xml"
        guard let slideEntry = archive[slidePath] else {
            throw PPTXError.missingRequiredFile(slidePath)
        }
        
        var slideData = Data()
        do {
            _ = try archive.extract(slideEntry) { data in
                slideData.append(data)
            }
        } catch {
            throw PPTXError.corruptedArchive
        }
        
        // Parse slide content
        let parser = PPTXXMLParser()
        let (title, textContent, shapeCount) = try parser.parseSlide(data: slideData)
        
        // Check for slide relationships (images, etc.)
        var slideRelationships: [Relationship] = []
        let slideRelsPath = "ppt/slides/_rels/\(slide.id).xml.rels"
        if let relsEntry = archive[slideRelsPath] {
            var relsData = Data()
            do {
                _ = try archive.extract(relsEntry) { data in
                    relsData.append(data)
                }
                
                // Parse relationships to find media
                let relsParser = XMLParser(data: relsData)
                let relsDelegate = SlideRelationshipsParser()
                relsParser.delegate = relsDelegate
                _ = relsParser.parse()
                
                slideRelationships = relsDelegate.relationships
            } catch {
                // Relationships are optional
            }
        }
        
        // TODO: Get layout type from slide layout
        
        return Slide(
            id: slide.id,
            index: slide.index,
            layoutType: nil, // Will be populated when we parse layouts
            title: title,
            shapeCount: shapeCount,
            notes: nil, // TODO: Parse notes if needed
            relationships: slideRelationships,
            textContent: textContent
        )
    }
    
    /// Get presentation metadata
    public func getMetadata() throws -> PresentationMetadata {
        guard let archive = self.archive else {
            throw PPTXError.corruptedArchive
        }
        
        var metadata = PresentationMetadata()
        
        // Get slide count
        metadata = PresentationMetadata(slideCount: try getSlideCount())
        
        // Parse core properties
        if let coreEntry = archive["docProps/core.xml"] {
            var coreData = Data()
            do {
                _ = try archive.extract(coreEntry) { data in
                    coreData.append(data)
                }
                
                let parser = MetadataXMLParser()
                let coreProps = try parser.parseCoreProperties(data: coreData)
                
                metadata = PresentationMetadata(
                    title: coreProps.title,
                    author: coreProps.creator,
                    created: coreProps.created,
                    modified: coreProps.modified,
                    company: metadata.company,
                    slideCount: metadata.slideCount,
                    masterCount: metadata.masterCount,
                    layoutsUsed: metadata.layoutsUsed,
                    mediaCount: metadata.mediaCount,
                    application: metadata.application,
                    appVersion: metadata.appVersion
                )
            } catch {
                // Core properties are optional
            }
        }
        
        // Parse app properties
        if let appEntry = archive["docProps/app.xml"] {
            var appData = Data()
            do {
                _ = try archive.extract(appEntry) { data in
                    appData.append(data)
                }
                
                let parser = MetadataXMLParser()
                let appProps = try parser.parseAppProperties(data: appData)
                
                metadata = PresentationMetadata(
                    title: metadata.title ?? appProps.presentationFormat,
                    author: metadata.author,
                    created: metadata.created,
                    modified: metadata.modified,
                    company: appProps.company,
                    slideCount: metadata.slideCount,
                    masterCount: metadata.masterCount,
                    layoutsUsed: metadata.layoutsUsed,
                    mediaCount: metadata.mediaCount,
                    application: appProps.application,
                    appVersion: appProps.appVersion
                )
            } catch {
                // App properties are optional
            }
        }
        
        // Count media files
        var mediaCount = 0
        for entry in archive {
            if entry.path.hasPrefix("ppt/media/") {
                mediaCount += 1
            }
        }
        
        metadata = PresentationMetadata(
            title: metadata.title,
            author: metadata.author,
            created: metadata.created,
            modified: metadata.modified,
            company: metadata.company,
            slideCount: metadata.slideCount,
            masterCount: metadata.masterCount,
            layoutsUsed: metadata.layoutsUsed,
            mediaCount: mediaCount,
            application: metadata.application,
            appVersion: metadata.appVersion
        )
        
        return metadata
    }
}