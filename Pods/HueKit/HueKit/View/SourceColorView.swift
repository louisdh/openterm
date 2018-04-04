//
//  SourceColorView.swift
//  HueKit
//
//  Created by Louis D'hauwe on 30/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class SourceColorView: UIControl {

	@IBInspectable
	open var isTrackingInside: Bool = false {
		didSet {
			if oldValue != isTrackingInside {
				self.setNeedsDisplay()
			}
		}
	}
	
	@IBInspectable
	open var dontShrinkWhenPressed: Bool = false {
		didSet {
			if oldValue != dontShrinkWhenPressed {
				self.setNeedsDisplay()
			}
		}
	}
	
	open override func draw(_ rect: CGRect) {
		super.draw(rect)
	
		guard isEnabled && isTrackingInside && !dontShrinkWhenPressed else {
			return
		}
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		
		let bounds = self.bounds
		
		UIColor.white.set()
		context.stroke(bounds.insetBy(dx: 1, dy: 1), width: 2)
		
		UIColor.black.set()
		UIRectFrame(bounds.insetBy(dx: 2, dy: 2))
	}
	
	// MARK: - UIControl overrides
	
	open override func beginTracking(_ touch: UITouch,  with event: UIEvent?) -> Bool {

		guard self.isEnabled else {
			return false
		}
		
		self.isTrackingInside = true
		
		return super.beginTracking(touch, with: event)
	}
	
	open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		
		let isTrackingInside = self.bounds.contains(touch.location(in: self))
	
		self.isTrackingInside = isTrackingInside
	
		return super.continueTracking(touch, with: event)
	}
	
	open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
	
		self.isTrackingInside = false
	
		super.endTracking(touch, with: event)
	}
	
	open override func cancelTracking(with event: UIEvent?) {
	
		self.isTrackingInside = false
	
		super.cancelTracking(with: event)
	}
	
}
