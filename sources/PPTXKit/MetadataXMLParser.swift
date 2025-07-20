import Foundation

/// Parser for metadata XML files (core.xml and app.xml)
class MetadataXMLParser: NSObject {
    
    struct CoreProperties {
        var title: String?
        var creator: String?
        var lastModifiedBy: String?
        var created: Date?
        var modified: Date?
    }
    
    struct AppProperties {
        var application: String?
        var appVersion: String?
        var company: String?
        var presentationFormat: String?
    }
    
    private var currentElement = ""
    private var currentValue = ""
    private var coreProps = CoreProperties()
    private var appProps = AppProperties()
    
    /// Parse core properties from docProps/core.xml
    func parseCoreProperties(data: Data) throws -> CoreProperties {
        coreProps = CoreProperties()
        currentElement = ""
        currentValue = ""
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        guard parser.parse() else {
            if let error = parser.parserError {
                throw PPTXDocument.PPTXError.invalidXML("core.xml: \(error.localizedDescription)")
            } else {
                throw PPTXDocument.PPTXError.invalidXML("core.xml")
            }
        }
        
        return coreProps
    }
    
    /// Parse app properties from docProps/app.xml
    func parseAppProperties(data: Data) throws -> AppProperties {
        appProps = AppProperties()
        currentElement = ""
        currentValue = ""
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        guard parser.parse() else {
            if let error = parser.parserError {
                throw PPTXDocument.PPTXError.invalidXML("app.xml: \(error.localizedDescription)")
            } else {
                throw PPTXDocument.PPTXError.invalidXML("app.xml")
            }
        }
        
        return appProps
    }
}

// MARK: - XMLParserDelegate
extension MetadataXMLParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentValue = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmedValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Core properties
        switch elementName {
        case "dc:title":
            coreProps.title = trimmedValue.isEmpty ? nil : trimmedValue
        case "dc:creator":
            coreProps.creator = trimmedValue.isEmpty ? nil : trimmedValue
        case "cp:lastModifiedBy":
            coreProps.lastModifiedBy = trimmedValue.isEmpty ? nil : trimmedValue
        case "dcterms:created":
            coreProps.created = ISO8601DateFormatter().date(from: trimmedValue)
        case "dcterms:modified":
            coreProps.modified = ISO8601DateFormatter().date(from: trimmedValue)
            
        // App properties
        case "Application":
            appProps.application = trimmedValue.isEmpty ? nil : trimmedValue
        case "AppVersion":
            appProps.appVersion = trimmedValue.isEmpty ? nil : trimmedValue
        case "Company":
            appProps.company = trimmedValue.isEmpty ? nil : trimmedValue
        case "PresentationFormat":
            appProps.presentationFormat = trimmedValue.isEmpty ? nil : trimmedValue
        default:
            break
        }
        
        currentValue = ""
    }
}