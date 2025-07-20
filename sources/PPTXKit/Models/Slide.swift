import Foundation

/// Represents a single slide in a PPTX presentation
public struct Slide {
	/// Slide ID (e.g., "slide1", "slide2")
	public let id: String
	
	/// 1-based index of the slide in the presentation
	public let index: Int
	
	/// Slide layout type
	public let layoutType: String?
	
	/// Slide title (if present)
	public let title: String?
	
	/// Number of shapes on the slide
	public let shapeCount: Int
	
	/// Slide notes (if present)
	public let notes: String?
	
	/// Related resources (images, charts, etc.)
	public let relationships: [Relationship]
	
	/// Text content extracted from the slide
	public let textContent: [String]
	
	/// Raw XML data of the slide (for detailed parsing)
	public let rawXMLData: Data?
	
	public init(
		id: String,
		index: Int,
		layoutType: String? = nil,
		title: String? = nil,
		shapeCount: Int = 0,
		notes: String? = nil,
		relationships: [Relationship] = [],
		textContent: [String] = [],
		rawXMLData: Data? = nil
	) {
		self.id = id
		self.index = index
		self.layoutType = layoutType
		self.title = title
		self.shapeCount = shapeCount
		self.notes = notes
		self.relationships = relationships
		self.textContent = textContent
		self.rawXMLData = rawXMLData
	}
}

/// Represents a relationship to another resource
public struct Relationship {
	public enum RelationshipType {
		case image
		case chart
		case diagram
		case media
		case other(String)
	}
	
	public let id: String
	public let type: RelationshipType
	public let target: String
	
	public init(id: String, type: RelationshipType, target: String) {
		self.id = id
		self.type = type
		self.target = target
	}
}