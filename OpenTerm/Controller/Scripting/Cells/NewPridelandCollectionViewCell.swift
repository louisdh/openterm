//
//  NewPridelandCollectionViewCell.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 14/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit
import BezierPathLength

class NewPridelandCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		self.setNeedsDisplay()
		
	}
	
	override func draw(_ rect: CGRect) {
		
		let lineWidth: CGFloat = 2.0
		
		let pathRect = rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)
		let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 16.0)
		
		UIColor.white.setStroke()
		
		let dashLength = path.length / (rect.height)
		
		path.setLineDash([dashLength], count: 1, phase: dashLength)
		path.lineWidth = lineWidth
		path.lineCapStyle = .round
		path.stroke()
		
	}
	
}
