//
//  PathElement.swift
//  BezierPathLength
//
//  Partially based on: https://gist.github.com/zwaldowski/e6aa7f3f81303a688ad4
//
//  Created by Louis D'hauwe on 18/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

/// Swifty version of `CGPathElement` & `CGPathElementType`
enum PathElement {
	
	/// The path element that starts a new subpath. The element holds a single point for the destination.
	case move(to: CGPoint)
	
	/// The path element that adds a line from the current point to a new point. The element holds a single point for the destination.
	case addLine(to: CGPoint)

	/// The path element that adds a quadratic curve from the current point to the specified point. The element holds a control point and a destination point.
	case addQuadCurve(CGPoint, to: CGPoint)
	
	/// The path element that adds a cubic curve from the current point to the specified point. The element holds two control points and a destination point.
	case addCurve(CGPoint, CGPoint, to: CGPoint)
	
	/// The path element that closes and completes a subpath. The element does not contain any points.
	case closeSubpath
	
	init(element: CGPathElement) {
		switch element.type {
		case .moveToPoint:
			self = .move(to: element.points[0])
		case .addLineToPoint:
			self = .addLine(to: element.points[0])
		case .addQuadCurveToPoint:
			self = .addQuadCurve(element.points[0], to: element.points[1])
		case .addCurveToPoint:
			self = .addCurve(element.points[0], element.points[1], to: element.points[2])
		case .closeSubpath:
			self = .closeSubpath
		}
	}
}

extension CGPath {
	
	typealias PathApplier = @convention(block) (UnsafePointer<CGPathElement>) -> Void
	
	func apply(with applier: PathApplier) {
		
		let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
			
			let block = unsafeBitCast(info, to: PathApplier.self)
			block(element)
			
		}
		
		self.apply(info: unsafeBitCast(applier, to: UnsafeMutableRawPointer.self), function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
	}
	
	var elements: [PathElement] {
		var pathElements = [PathElement]()
		
		apply { (element) in
			
			let pathElement = PathElement(element: element.pointee)
			pathElements.append(pathElement)
			
		}
		
		return pathElements
	}
	
}
