import Foundation

/// Metadata about a PPTX presentation
public struct PresentationMetadata {
    /// Presentation title
    public let title: String?
    
    /// Author information
    public let author: String?
    
    /// Creation date
    public let created: Date?
    
    /// Last modification date
    public let modified: Date?
    
    /// Company/organization
    public let company: String?
    
    /// Number of slides
    public let slideCount: Int
    
    /// Number of slide masters
    public let masterCount: Int
    
    /// Layout types used
    public let layoutsUsed: Set<String>
    
    /// Number of media assets (images, videos, etc.)
    public let mediaCount: Int
    
    /// Application that created the file
    public let application: String?
    
    /// Application version
    public let appVersion: String?
    
    public init(
        title: String? = nil,
        author: String? = nil,
        created: Date? = nil,
        modified: Date? = nil,
        company: String? = nil,
        slideCount: Int = 0,
        masterCount: Int = 0,
        layoutsUsed: Set<String> = [],
        mediaCount: Int = 0,
        application: String? = nil,
        appVersion: String? = nil
    ) {
        self.title = title
        self.author = author
        self.created = created
        self.modified = modified
        self.company = company
        self.slideCount = slideCount
        self.masterCount = masterCount
        self.layoutsUsed = layoutsUsed
        self.mediaCount = mediaCount
        self.application = application
        self.appVersion = appVersion
    }
}