import Foundation
import CoreGraphics

/// Represents a PowerPoint theme with color schemes, fonts, and formatting
public struct Theme {
	public let name: String
	public let colorScheme: ColorScheme
	public let fontScheme: FontScheme
	public let formatScheme: FormatScheme
	
	public init(name: String, colorScheme: ColorScheme, fontScheme: FontScheme, formatScheme: FormatScheme) {
		self.name = name
		self.colorScheme = colorScheme
		self.fontScheme = fontScheme
		self.formatScheme = formatScheme
	}
}

/// Color scheme defining the theme colors
public struct ColorScheme {
	public let name: String
	
	// Dark colors
	public let dark1: ThemeColor
	public let dark2: ThemeColor
	
	// Light colors
	public let light1: ThemeColor
	public let light2: ThemeColor
	
	// Accent colors
	public let accent1: ThemeColor
	public let accent2: ThemeColor
	public let accent3: ThemeColor
	public let accent4: ThemeColor
	public let accent5: ThemeColor
	public let accent6: ThemeColor
	
	// Hyperlink colors
	public let hyperlink: ThemeColor
	public let followedHyperlink: ThemeColor
	
	public init(
		name: String,
		dark1: ThemeColor,
		dark2: ThemeColor,
		light1: ThemeColor,
		light2: ThemeColor,
		accent1: ThemeColor,
		accent2: ThemeColor,
		accent3: ThemeColor,
		accent4: ThemeColor,
		accent5: ThemeColor,
		accent6: ThemeColor,
		hyperlink: ThemeColor,
		followedHyperlink: ThemeColor
	) {
		self.name = name
		self.dark1 = dark1
		self.dark2 = dark2
		self.light1 = light1
		self.light2 = light2
		self.accent1 = accent1
		self.accent2 = accent2
		self.accent3 = accent3
		self.accent4 = accent4
		self.accent5 = accent5
		self.accent6 = accent6
		self.hyperlink = hyperlink
		self.followedHyperlink = followedHyperlink
	}
	
	/// Get a theme color by its scheme name
	public func color(for schemeName: String) -> ThemeColor? {
		switch schemeName.lowercased() {
		case "dk1", "dark1": return dark1
		case "dk2", "dark2": return dark2
		case "lt1", "light1": return light1
		case "lt2", "light2": return light2
		case "accent1": return accent1
		case "accent2": return accent2
		case "accent3": return accent3
		case "accent4": return accent4
		case "accent5": return accent5
		case "accent6": return accent6
		case "hlink", "hyperlink": return hyperlink
		case "folhlink", "followedhyperlink": return followedHyperlink
		default: return nil
		}
	}
}

/// Represents a theme color with its value and type
public struct ThemeColor {
	public enum ColorType {
		case rgb(String) // Hex RGB value
		case system(String, lastColor: String?) // System color with optional last color
	}
	
	public let type: ColorType
	
	public init(type: ColorType) {
		self.type = type
	}
	
	/// Get the color value as hex string
	public var hexValue: String {
		switch type {
		case .rgb(let hex):
			return hex
		case .system(_, let lastColor):
			// For system colors, use the lastColor if available
			// Otherwise use default values
			if let lastColor = lastColor {
				return lastColor
			} else {
				// Default system colors
				return "000000" // Default to black, can be improved
			}
		}
	}
	
	/// Convert to CGColor
	public var cgColor: CGColor {
		let hex = hexValue
		guard hex.count == 6,
			  let r = Int(hex.prefix(2), radix: 16),
			  let g = Int(hex.dropFirst(2).prefix(2), radix: 16),
			  let b = Int(hex.dropFirst(4).prefix(2), radix: 16) else {
			return CGColor(red: 0, green: 0, blue: 0, alpha: 1)
		}
		
		return CGColor(
			red: CGFloat(r) / 255.0,
			green: CGFloat(g) / 255.0,
			blue: CGFloat(b) / 255.0,
			alpha: 1.0
		)
	}
}

/// Font scheme defining major and minor fonts
public struct FontScheme {
	public let name: String
	public let majorFont: FontCollection
	public let minorFont: FontCollection
	
	public init(name: String, majorFont: FontCollection, minorFont: FontCollection) {
		self.name = name
		self.majorFont = majorFont
		self.minorFont = minorFont
	}
}

/// Collection of fonts for different scripts
public struct FontCollection {
	public let latin: String
	public let eastAsian: String?
	public let complexScript: String?
	public let supplementalFonts: [String: String] // script -> typeface
	
	public init(latin: String, eastAsian: String? = nil, complexScript: String? = nil, supplementalFonts: [String: String] = [:]) {
		self.latin = latin
		self.eastAsian = eastAsian
		self.complexScript = complexScript
		self.supplementalFonts = supplementalFonts
	}
}

/// Format scheme with fill, line, and effect styles
public struct FormatScheme {
	public let name: String
	// For now, we'll keep this simple
	// Can be expanded later to include fillStyleList, lineStyleList, effectStyleList
	
	public init(name: String) {
		self.name = name
	}
}

/// Extensions for color manipulation
extension ThemeColor {
	/// Apply tint (lighten) to the color
	public func withTint(_ tintValue: Int) -> CGColor {
		let tint = CGFloat(tintValue) / 100000.0
		let baseColor = self.cgColor
		
		guard let components = baseColor.components, components.count >= 3 else {
			return baseColor
		}
		
		let r = components[0] + (1.0 - components[0]) * tint
		let g = components[1] + (1.0 - components[1]) * tint
		let b = components[2] + (1.0 - components[2]) * tint
		
		return CGColor(red: r, green: g, blue: b, alpha: baseColor.alpha)
	}
	
	/// Apply shade (darken) to the color
	public func withShade(_ shadeValue: Int) -> CGColor {
		let shade = CGFloat(shadeValue) / 100000.0
		let baseColor = self.cgColor
		
		guard let components = baseColor.components, components.count >= 3 else {
			return baseColor
		}
		
		let r = components[0] * shade
		let g = components[1] * shade
		let b = components[2] * shade
		
		return CGColor(red: r, green: g, blue: b, alpha: baseColor.alpha)
	}
}