import Foundation

/// Parser for slide relationship files
class SlideRelationshipsParser: NSObject, XMLParserDelegate {
	var relationships: [Relationship] = []
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "Relationship" {
			print("[SlideRelationshipsParser] Found Relationship element")
			print("[SlideRelationshipsParser] Attributes: \(attributeDict)")
			
			guard let id = attributeDict["Id"],
				  let target = attributeDict["Target"],
				  let type = attributeDict["Type"] else {
				print("[SlideRelationshipsParser] Missing required attributes")
				return
			}
			
			let relType: Relationship.RelationshipType
			
			if type.contains("image") {
				relType = .image
			} else if type.contains("chart") {
				relType = .chart
			} else if type.contains("diagram") {
				relType = .diagram
			} else if type.contains("video") || type.contains("audio") || type.contains("media") {
				relType = .media
			} else {
				relType = .other(type)
			}
			
			let relationship = Relationship(id: id, type: relType, target: target)
			relationships.append(relationship)
			print("[SlideRelationshipsParser] Added relationship: \(id) -> \(target) (type: \(relType))")
		}
	}
}