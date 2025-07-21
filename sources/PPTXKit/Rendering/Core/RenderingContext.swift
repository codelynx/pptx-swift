import Foundation
import CoreGraphics

/// Context for rendering PPTX slides
public struct RenderingContext {
	/// Target size for rendering in points
	public let size: CGSize
	
	/// Rendering scale factor (e.g., 2.0 for Retina)
	public let scale: CGFloat
	
	/// Rendering quality settings
	public let quality: RenderingQuality
	
	/// Rendering options
	public let options: RenderingOptions
	
	/// Slide dimensions from PPTX (in EMUs)
	public let slideSize: SlideSize
	
	public init(
		size: CGSize,
		scale: CGFloat = 1.0,
		quality: RenderingQuality = .balanced,
		options: RenderingOptions = RenderingOptions(),
		slideSize: SlideSize = .standard4x3
	) {
		self.size = size
		self.scale = scale
		self.quality = quality
		self.options = options
		self.slideSize = slideSize
	}
	
	/// Convert EMUs to points
	public func emuToPoints(_ emu: Int) -> CGFloat {
		// 1 point = 12,700 EMUs
		return CGFloat(emu) / 12700.0
	}
	
	/// Convert EMUs to scaled pixels
	public func emuToPixels(_ emu: Int) -> CGFloat {
		return emuToPoints(emu) * scale
	}
	
	/// Get scale factor to fit slide in target size
	public var fitScale: CGFloat {
		let slideWidth = emuToPoints(slideSize.width)
		let slideHeight = emuToPoints(slideSize.height)
		
		let widthScale = size.width / slideWidth
		let heightScale = size.height / slideHeight
		
		return min(widthScale, heightScale)
	}
	
	/// Transform EMU coordinates to view coordinates
	public func transform(point: CGPoint) -> CGPoint {
		let scale = fitScale
		return CGPoint(
			x: emuToPoints(Int(point.x)) * scale,
			y: emuToPoints(Int(point.y)) * scale
		)
	}
	
	/// Transform EMU rectangle to view coordinates
	public func transform(rect: CGRect) -> CGRect {
		let origin = transform(point: rect.origin)
		let size = CGSize(
			width: emuToPoints(Int(rect.width)) * fitScale,
			height: emuToPoints(Int(rect.height)) * fitScale
		)
		return CGRect(origin: origin, size: size)
	}
}

/// Rendering quality levels
public enum RenderingQuality {
	/// Fast rendering with basic shapes only
	case low
	
	/// Balanced quality and performance
	case balanced
	
	/// Best quality with all effects
	case high
	
	/// Should render gradients?
	public var rendersGradients: Bool {
		switch self {
		case .low: return false
		case .balanced, .high: return true
		}
	}
	
	/// Should render shadows?
	public var rendersShadows: Bool {
		switch self {
		case .low: return false
		case .balanced, .high: return true
		}
	}
	
	/// Should render complex shapes?
	public var rendersComplexShapes: Bool {
		switch self {
		case .low: return false
		case .balanced, .high: return true
		}
	}
	
	/// Text rendering quality
	public var textQuality: CGInterpolationQuality {
		switch self {
		case .low: return .low
		case .balanced: return .default
		case .high: return .high
		}
	}
}

/// Rendering options
public struct RenderingOptions {
	/// Render text elements
	public var renderText: Bool = true
	
	/// Render image elements
	public var renderImages: Bool = true
	
	/// Render shape elements
	public var renderShapes: Bool = true
	
	/// Render background
	public var renderBackground: Bool = true
	
	/// Render placeholders when content is missing
	public var renderPlaceholders: Bool = true
	
	/// Maximum time to wait for image loading
	public var imageLoadingTimeout: TimeInterval = 5.0
	
	/// Cache rendered elements
	public var enableCache: Bool = true
	
	public init() {}
}

/// Standard slide sizes in EMUs
public struct SlideSize {
	public let width: Int
	public let height: Int
	
	/// Standard 4:3 aspect ratio (default)
	public static let standard4x3 = SlideSize(width: 9144000, height: 6858000)
	
	/// Widescreen 16:9 aspect ratio
	public static let widescreen16x9 = SlideSize(width: 9144000, height: 5143500)
	
	/// Widescreen 16:10 aspect ratio
	public static let widescreen16x10 = SlideSize(width: 9144000, height: 5715000)
	
	public init(width: Int, height: Int) {
		self.width = width
		self.height = height
	}
}