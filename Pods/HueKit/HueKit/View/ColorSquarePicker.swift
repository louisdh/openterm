//
//  ColorSquarePicker.swift
//  HueKit
//
//  Created by Louis D'hauwe on 30/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ColorSquarePicker: UIControl {

	private let contentInsetX: CGFloat = 20
	private let contentInsetY: CGFloat = 20
	
	private let indicatorSizeInactive: CGFloat = 24
	private let indicatorSizeActive: CGFloat = 40
	
	private lazy var colorSquareView: ColorSquareView = {
		return ColorSquareView()
	}()
	
	open lazy var indicator: ColorIndicatorView = {
		
		let size = CGSize(width: self.indicatorSizeInactive, height: self.indicatorSizeInactive)
		let indicatorRect = CGRect(origin: .zero, size: size)
			
		return ColorIndicatorView(frame: indicatorRect)
	}()
	
	@IBInspectable
	public var hue: CGFloat = 0.0 {
		didSet {
			if oldValue != hue {
				self.setIndicatorColor()
			}
		}
	}

	@IBInspectable
	public var value: CGPoint = .zero {
		didSet {
			if oldValue != value {
				
				self.sendActions(for: .valueChanged)
				self.setNeedsLayout()
			}
		}
	}
	
	public var color: UIColor {
		return  UIColor(hue: hue, saturation: value.x, brightness: value.y, alpha: 1.0)
	}

	private func setIndicatorColor() {
	
		colorSquareView.hue = hue
		indicator.color = color
	}
	
	open override func layoutSubviews() {
	
		if colorSquareView.superview == nil {
			
			colorSquareView.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(colorSquareView)
			
			colorSquareView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInsetX).isActive = true
			colorSquareView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentInsetX).isActive = true
			colorSquareView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInsetY).isActive = true
			colorSquareView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentInsetY).isActive = true
			
		}
		
		if indicator.superview == nil {
			self.addSubview(indicator)
		}
		
		self.setIndicatorColor()
		
		let indicatorX = contentInsetX + (self.value.x * (self.bounds.size.width - 2 * contentInsetX))
		let indicatorY = self.bounds.size.height - contentInsetY - (self.value.y * (self.bounds.size.height - 2 * contentInsetY))
		
		indicator.center = CGPoint(x: indicatorX, y: indicatorY)
	}
	
	// MARK: - Tracking
	
	private func trackIndicator(with touch: UITouch) {
		let bounds = self.bounds
		
		var touchValue = CGPoint(x: 0, y: 0)
		
		touchValue.x = (touch.location(in: self).x - contentInsetX) / (bounds.size.width - 2 * contentInsetX)
		
		touchValue.y = (touch.location(in: self).y - contentInsetY) / (bounds.size.height - 2 * contentInsetY)
		
		
		touchValue.x = touchValue.x.pinned(between: 0, and: 1)
		touchValue.y = 1.0 - touchValue.y.pinned(between: 0, and: 1)
		
		self.value = touchValue
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
	
	private func changeIndicatorSize(to size: CGFloat) {
		
		let center = self.indicator.center

		let size = CGSize(width: size, height: size)
		let indicatorRect = CGRect(origin: .zero, size: size)
		
		self.indicator.frame = indicatorRect
		self.indicator.center = center
		
	}
	
	private func growIndicator() {
		
		UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseIn], animations: { 

			self.changeIndicatorSize(to: self.indicatorSizeActive)
			
		}) { (finished) in
			
		}
		
	}
	
	private func shrinkIndicator() {
		
		UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut], animations: {
			
			self.changeIndicatorSize(to: self.indicatorSizeInactive)
			self.indicator.setNeedsDisplay()

		}) { (finished) in

			self.indicator.setNeedsDisplay()

		}

	}

}
