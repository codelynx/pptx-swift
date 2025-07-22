import Foundation
import ZIPFoundation

/// Parser for PowerPoint theme files
public class ThemeParser {
	
	/// Parse theme from a PPTX archive
	public func parseTheme(from archive: Archive) throws -> Theme? {
		// Theme is typically at ppt/theme/theme1.xml
		let themePath = "ppt/theme/theme1.xml"
		
		guard let entry = archive[themePath] else {
			print("No theme found at \(themePath)")
			return nil
		}
		
		var xmlData = Data()
		_ = try archive.extract(entry) { data in
			xmlData.append(data)
		}
		
		return try parseTheme(from: xmlData)
	}
	
	/// Parse theme from XML data
	public func parseTheme(from data: Data) throws -> Theme {
		let parser = XMLParser(data: data)
		let delegate = ThemeXMLParserDelegate()
		parser.delegate = delegate
		
		guard parser.parse() else {
			throw PPTXDocument.PPTXError.invalidXML("theme")
		}
		
		guard let theme = delegate.theme else {
			throw PPTXDocument.PPTXError.invalidXML("theme")
		}
		
		return theme
	}
}

/// XML Parser delegate for theme files
private class ThemeXMLParserDelegate: NSObject, XMLParserDelegate {
	var theme: Theme?
	
	// Parsing state
	private var currentElement = ""
	private var currentColorScheme: String?
	private var currentFontScheme: String?
	
	// Color scheme colors
	private var colors: [String: ThemeColor] = [:]
	
	// Font scheme fonts
	private var majorFontLatin: String?
	private var minorFontLatin: String?
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		currentElement = elementName
		
		switch elementName {
		case "a:theme":
			let themeName = attributeDict["name"] ?? "Theme"
			currentColorScheme = themeName
			
		case "a:clrScheme":
			currentColorScheme = attributeDict["name"] ?? "ColorScheme"
			
		case "a:fontScheme":
			currentFontScheme = attributeDict["name"] ?? "FontScheme"
			
		case "a:srgbClr":
			// RGB color value
			if let val = attributeDict["val"] {
				setCurrentColor(ThemeColor(type: .rgb(val)))
			}
			
		case "a:sysClr":
			// System color
			if let val = attributeDict["val"] {
				let lastClr = attributeDict["lastClr"]
				setCurrentColor(ThemeColor(type: .system(val, lastColor: lastClr)))
			}
			
		case "a:latin":
			// Latin font
			if let typeface = attributeDict["typeface"] {
				if isInMajorFont() {
					majorFontLatin = typeface
				} else if isInMinorFont() {
					minorFontLatin = typeface
				}
			}
		
		default:
			break
		}
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		// Create theme from parsed data
		let colorScheme = ColorScheme(
			name: currentColorScheme ?? "Default",
			dark1: colors["dk1"] ?? ThemeColor(type: .rgb("000000")),
			dark2: colors["dk2"] ?? ThemeColor(type: .rgb("1F497D")),
			light1: colors["lt1"] ?? ThemeColor(type: .rgb("FFFFFF")),
			light2: colors["lt2"] ?? ThemeColor(type: .rgb("EEECE1")),
			accent1: colors["accent1"] ?? ThemeColor(type: .rgb("4F81BD")),
			accent2: colors["accent2"] ?? ThemeColor(type: .rgb("C0504D")),
			accent3: colors["accent3"] ?? ThemeColor(type: .rgb("9BBB59")),
			accent4: colors["accent4"] ?? ThemeColor(type: .rgb("8064A2")),
			accent5: colors["accent5"] ?? ThemeColor(type: .rgb("4BACC6")),
			accent6: colors["accent6"] ?? ThemeColor(type: .rgb("F79646")),
			hyperlink: colors["hlink"] ?? ThemeColor(type: .rgb("0000FF")),
			followedHyperlink: colors["folHlink"] ?? ThemeColor(type: .rgb("800080"))
		)
		
		let fontScheme = FontScheme(
			name: currentFontScheme ?? "Default",
			majorFont: FontCollection(latin: majorFontLatin ?? "Calibri Light"),
			minorFont: FontCollection(latin: minorFontLatin ?? "Calibri")
		)
		
		let formatScheme = FormatScheme(name: "Default")
		
		theme = Theme(
			name: currentColorScheme ?? "Theme",
			colorScheme: colorScheme,
			fontScheme: fontScheme,
			formatScheme: formatScheme
		)
	}
	
	// Helper methods
	private func setCurrentColor(_ color: ThemeColor) {
		// Determine which color we're setting based on parent element
		let parentElements = ["dk1", "dk2", "lt1", "lt2", "accent1", "accent2", "accent3", "accent4", "accent5", "accent6", "hlink", "folHlink"]
		
		for parent in parentElements {
			if currentElement.contains(parent) || isInElement("a:\(parent)") {
				colors[parent] = color
				break
			}
		}
	}
	
	private func isInElement(_ elementName: String) -> Bool {
		// This is a simplified check - in production, you'd track the element stack
		return currentElement.contains(elementName)
	}
	
	private func isInMajorFont() -> Bool {
		return currentElement.contains("majorFont")
	}
	
	private func isInMinorFont() -> Bool {
		return currentElement.contains("minorFont")
	}
}

// MARK: - More robust XML parsing with element tracking

/// Enhanced XML parser delegate that properly tracks element hierarchy
private class ThemeXMLParserDelegateV2: NSObject, XMLParserDelegate {
	var theme: Theme?
	
	// Element stack to track hierarchy
	private var elementStack: [String] = []
	private var currentText = ""
	
	// Parsed data
	private var themeName = "Theme"
	private var colorSchemeName = "ColorScheme"
	private var colors: [String: ThemeColor] = [:]
	private var majorFontLatin = "Calibri Light"
	private var minorFontLatin = "Calibri"
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		elementStack.append(elementName)
		currentText = ""
		
		// Remove namespace prefix for easier handling
		let element = elementName.replacingOccurrences(of: "a:", with: "")
		
		switch element {
		case "theme":
			themeName = attributeDict["name"] ?? "Theme"
			
		case "clrScheme":
			colorSchemeName = attributeDict["name"] ?? "ColorScheme"
			
		case "srgbClr":
			if let val = attributeDict["val"], let colorKey = getCurrentColorKey() {
				colors[colorKey] = ThemeColor(type: .rgb(val))
			}
			
		case "sysClr":
			if let val = attributeDict["val"], let colorKey = getCurrentColorKey() {
				let lastClr = attributeDict["lastClr"]
				colors[colorKey] = ThemeColor(type: .system(val, lastColor: lastClr))
			}
			
		case "latin":
			if let typeface = attributeDict["typeface"] {
				if isInMajorFont() {
					majorFontLatin = typeface
				} else if isInMinorFont() {
					minorFontLatin = typeface
				}
			}
			
		default:
			break
		}
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		elementStack.removeLast()
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		// Create theme from parsed data
		let colorScheme = ColorScheme(
			name: colorSchemeName,
			dark1: colors["dk1"] ?? ThemeColor(type: .rgb("000000")),
			dark2: colors["dk2"] ?? ThemeColor(type: .rgb("1F497D")),
			light1: colors["lt1"] ?? ThemeColor(type: .rgb("FFFFFF")),
			light2: colors["lt2"] ?? ThemeColor(type: .rgb("EEECE1")),
			accent1: colors["accent1"] ?? ThemeColor(type: .rgb("4F81BD")),
			accent2: colors["accent2"] ?? ThemeColor(type: .rgb("C0504D")),
			accent3: colors["accent3"] ?? ThemeColor(type: .rgb("9BBB59")),
			accent4: colors["accent4"] ?? ThemeColor(type: .rgb("8064A2")),
			accent5: colors["accent5"] ?? ThemeColor(type: .rgb("4BACC6")),
			accent6: colors["accent6"] ?? ThemeColor(type: .rgb("F79646")),
			hyperlink: colors["hlink"] ?? ThemeColor(type: .rgb("0000FF")),
			followedHyperlink: colors["folHlink"] ?? ThemeColor(type: .rgb("800080"))
		)
		
		let fontScheme = FontScheme(
			name: "Office",
			majorFont: FontCollection(latin: majorFontLatin),
			minorFont: FontCollection(latin: minorFontLatin)
		)
		
		let formatScheme = FormatScheme(name: "Office")
		
		theme = Theme(
			name: themeName,
			colorScheme: colorScheme,
			fontScheme: fontScheme,
			formatScheme: formatScheme
		)
	}
	
	// Helper methods
	private func getCurrentColorKey() -> String? {
		// Check if we're inside a color element
		let colorElements = ["dk1", "dk2", "lt1", "lt2", "accent1", "accent2", "accent3", "accent4", "accent5", "accent6", "hlink", "folHlink"]
		
		for element in elementStack.reversed() {
			let cleanElement = element.replacingOccurrences(of: "a:", with: "")
			if colorElements.contains(cleanElement) {
				return cleanElement
			}
		}
		
		return nil
	}
	
	private func isInMajorFont() -> Bool {
		return elementStack.contains("a:majorFont")
	}
	
	private func isInMinorFont() -> Bool {
		return elementStack.contains("a:minorFont")
	}
}

// Public extension for convenience
public extension ThemeParser {
	/// Parse theme using the enhanced parser
	func parseThemeV2(from data: Data) throws -> Theme {
		let parser = XMLParser(data: data)
		let delegate = ThemeXMLParserDelegateV2()
		parser.delegate = delegate
		
		guard parser.parse() else {
			throw PPTXDocument.PPTXError.invalidXML("theme")
		}
		
		guard let theme = delegate.theme else {
			throw PPTXDocument.PPTXError.invalidXML("theme")
		}
		
		return theme
	}
}