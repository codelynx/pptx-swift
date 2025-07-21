import CoreGraphics
import Foundation

// Common extensions used throughout PPTXKit

extension CGSize {
	/// Scales the size by the given factor
	func scaled(by factor: CGFloat) -> CGSize {
		return CGSize(width: width * factor, height: height * factor)
	}
	
	/// Returns the aspect ratio (width / height)
	var aspectRatio: CGFloat {
		guard height > 0 else { return 0 }
		return width / height
	}
	
	/// Fits this size within the target size while maintaining aspect ratio
	func aspectFit(within targetSize: CGSize) -> CGSize {
		let widthRatio = targetSize.width / width
		let heightRatio = targetSize.height / height
		let scaleFactor = min(widthRatio, heightRatio)
		return scaled(by: scaleFactor)
	}
}

extension CGRect {
	/// Returns the center point of the rectangle
	var center: CGPoint {
		return CGPoint(x: midX, y: midY)
	}
	
	/// Creates a rectangle with the given center and size
	init(center: CGPoint, size: CGSize) {
		self.init(
			x: center.x - size.width / 2,
			y: center.y - size.height / 2,
			width: size.width,
			height: size.height
		)
	}
	
	/// Insets the rectangle by the given edge insets
	func inset(by insets: EdgeInsets) -> CGRect {
		return CGRect(
			x: origin.x + insets.left,
			y: origin.y + insets.top,
			width: size.width - insets.left - insets.right,
			height: size.height - insets.top - insets.bottom
		)
	}
}

extension CGPoint {
	/// Returns the distance to another point
	func distance(to point: CGPoint) -> CGFloat {
		let dx = x - point.x
		let dy = y - point.y
		return sqrt(dx * dx + dy * dy)
	}
	
	/// Applies a transform to the point
	func applying(_ transform: CGAffineTransform) -> CGPoint {
		return CGPoint(
			x: x * transform.a + y * transform.c + transform.tx,
			y: x * transform.b + y * transform.d + transform.ty
		)
	}
}

// EdgeInsets compatibility
#if canImport(UIKit)
import UIKit
typealias EdgeInsets = UIEdgeInsets
#else
import AppKit
typealias EdgeInsets = NSEdgeInsets
#endif