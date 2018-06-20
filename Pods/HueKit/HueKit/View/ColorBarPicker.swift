//
//  ColorBarPicker.swift
//  HueKit
//
//  Created by Louis D'hauwe on 30/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ColorBarPicker: UIControl {
	
	private var isVertical: Bool = false {
		didSet {
			if isVertical != oldValue {
				updateOrientation()
			}
		}
	}
	
	private func updateVerticalState() {
		
//		let bounds = self.layer.presentation()?.bounds ?? self.bounds
		isVertical = bounds.height > bounds.width

	}
	
	
	private let contentInset: CGFloat = 20.0
	private static let indicatorSizeInactive = CGSize(width: 24.0, height: 24.0)
	private static let indicatorSizeActive = CGSize(width: 40.0, height: 40.0)
	
	@IBInspectable
	open var hue: CGFloat {
		get {
			if isVertical {
				return 1.0 - value
			} else {
				return value
			}
		}
		set {
			if isVertical {
				value = 1.0 - newValue
			} else {
				value = newValue
			}
		}
	}
	
	private var value: CGFloat = 0.0 {
		didSet {
			
			if oldValue != value {
				
				self.sendActions(for: .valueChanged)
				self.setNeedsLayout()
			}
			
		}
	}
	
	open lazy var colorBarView: ColorBarView = {
		return ColorBarView()
	}()
	
	private lazy var indicator: ColorIndicatorView = {
		
		let frame = CGRect(origin: .zero, size: ColorBarPicker.indicatorSizeInactive)
		let indicator = ColorIndicatorView(frame: frame)
		
		return indicator
		
	}()
	
	func updateOrientation() {
		
		guard colorBarView.superview != nil else {
			return
		}

		if isVertical {
			
			colorBarView.transform = .identity

			var rect = self.bounds
			rect.size.width = bounds.height - contentInset * 2
			rect.size.height = bounds.width

			colorBarView.frame = rect
			
			colorBarView.transform = CGAffineTransform(rotationAngle: -.pi / 2.0)
			
			colorBarView.frame.origin = CGPoint(x: 0, y: contentInset)
			
		} else {
			
			var rect = self.bounds
			rect.size.width -= contentInset * 2
			
			colorBarView.frame = rect
			
			colorBarView.transform = .identity

			colorBarView.frame.origin = CGPoint(x: contentInset, y: 0)

		}
		
	}
	
	// MARK: - Drawing
	
	override open func layoutSubviews() {
		
		if colorBarView.superview == nil {
			
			colorBarView.isUserInteractionEnabled = false

			colorBarView.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(colorBarView)
			
			updateOrientation()

		}
		
		if indicator.superview == nil {
			self.addSubview(indicator)
		}
		
		let wasVertical = isVertical
		
		updateVerticalState()
		
		if wasVertical != isVertical {

			value = 1.0 - value

		}
		
		updateOrientation()
//		colorBarView.setNeedsDisplay()
		
		indicator.color = UIColor(hue: hue,
		                          saturation: 1.0,
		                          brightness: 1.0,
		                          alpha: 1.0)
		
		if isVertical {
			
			let indicatorLoc = contentInset + (self.value * (self.bounds.size.height - 2 * contentInset))
			indicator.center = CGPoint(x: self.bounds.midX, y: indicatorLoc)

		} else {
			
			let indicatorLoc = contentInset + (self.value * (self.bounds.size.width - 2 * contentInset))
			indicator.center = CGPoint(x: indicatorLoc, y: self.bounds.midY)
			
		}

	}

	// MARK: - Tracking
	
	private func trackIndicator(with touch: UITouch) {
		
		let touchLocation = touch.location(in: self)
		
		let percent: CGFloat
		
		if isVertical {
			
			percent = (touchLocation.y - contentInset) / (self.bounds.size.height - 2 * contentInset)

		} else {
		
			percent = (touchLocation.x - contentInset) / (self.bounds.size.width - 2 * contentInset)

		}
		
		self.value = percent.pinned(between: 0, and: 1)
	}
	
	override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.trackIndicator(with: touch)
	
		growIndicator()
		return true
	}
	
	override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.trackIndicator(with: touch)
	
		return true
	}
	
	override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
		
		shrinkIndicator()
	}
	
	override open func cancelTracking(with event: UIEvent?) {
		super.cancelTracking(with: event)
		
		shrinkIndicator()
	}
	
	private func changeIndicatorSize(to size: CGSize) {
		
		let center = self.indicator.center
		
		let indicatorRect = CGRect(origin: .zero, size: size)
		
		self.indicator.frame = indicatorRect
		self.indicator.center = center
		
	}
	
	private func growIndicator() {
		
		UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseIn], animations: {
			
			self.changeIndicatorSize(to: ColorBarPicker.indicatorSizeActive)
			
		}) { (finished) in
			
		}
		
	}
	
	private func shrinkIndicator() {
		
		UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut], animations: {
			
			self.changeIndicatorSize(to: ColorBarPicker.indicatorSizeInactive)
			self.indicator.setNeedsDisplay()
			
		}) { (finished) in
			
			self.indicator.setNeedsDisplay()
			
		}
		
	}
	
	
	// MARK: - Accessibility
	
	private let accessibilityInterval: CGFloat = 0.05
	
	open override var accessibilityTraits: UIAccessibilityTraits {
		get {
			var t = super.accessibilityTraits
			
			t |= UIAccessibilityTraitAdjustable
			
			return t
		}
		set {
			super.accessibilityTraits = newValue
		}
	}
	
	open override func accessibilityIncrement() {
		
		var newValue = self.value + accessibilityInterval
		
		if newValue > 1.0 {
			newValue -= 1.0
		}
		
		self.value = newValue
	}
	
	open override func accessibilityDecrement() {
	
		var newValue = self.value - accessibilityInterval
		
		if newValue < 0 {
			newValue += 1.0
		}
		
		self.value = newValue
	}
	
	open override var accessibilityValue: String? {
		get {
			return String(format: "%d degrees hue", (self.value * 360.0))
		}
		set {
			super.accessibilityValue = newValue
		}
	}

}
