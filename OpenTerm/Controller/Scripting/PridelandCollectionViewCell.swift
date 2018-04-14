//
//  PridelandCollectionViewCell.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 01/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class GradientView: UIView {
	
	override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}
	
}

class PridelandCollectionViewCell: UICollectionViewCell {

	let gradientView = GradientView()

	var gradientLayer: CAGradientLayer? {
		return gradientView.layer as? CAGradientLayer
	}
	
	@IBOutlet weak var titleLbl: UILabel!
	@IBOutlet weak var descriptionLbl: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()

		gradientView.translatesAutoresizingMaskIntoConstraints = true
		self.contentView.insertSubview(gradientView, at: 0)

		gradientLayer?.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
		gradientLayer?.startPoint = .zero
		gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
		
		self.contentView.layer.cornerRadius = 16.0
		self.contentView.layer.masksToBounds = true
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		gradientView.frame = self.contentView.bounds

	}
	
	func show(_ prideland: PridelandOverview) {
		
		titleLbl.text = prideland.metadata.name
		descriptionLbl.text = prideland.metadata.description
		
		let hue = CGFloat(prideland.metadata.hueTint)
		
		updateGradient(hue: hue)
		
	}
	
	private func updateGradient(hue: CGFloat) {
		
		let gradientColor1: UIColor
		var gradientColor2: UIColor
		
		let hue2: CGFloat
		
		if hue < 0.1 {

			hue2 = 1.0 - (0.1 - hue)

		} else {
			
			hue2 = hue - 0.1
			
		}
		
		if hue > 0.1 && hue < 0.6 {

			gradientColor1 = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			gradientColor2 = UIColor(hue: hue2, saturation: 0.9, brightness: 0.5, alpha: 1.0)

		} else {

			gradientColor1 = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			gradientColor2 = UIColor(hue: hue2, saturation: 1.0, brightness: 1.0, alpha: 1.0)

		}
		
		var grayscale1: CGFloat = 0
		var grayscale2: CGFloat = 0

		gradientColor1.getWhite(&grayscale1, alpha: nil)
		gradientColor2.getWhite(&grayscale2, alpha: nil)
		
		if abs(grayscale1 - grayscale2) < 0.1 {
			
			gradientColor2 = UIColor(hue: hue2, saturation: 0.8, brightness: 0.6, alpha: 1.0)
			gradientColor2.getWhite(&grayscale2, alpha: nil)

		}
		
		// Gradient should always be light -> dark
		if grayscale1 < grayscale2 {
			
			gradientLayer?.colors = [gradientColor2.cgColor, gradientColor1.cgColor]

		} else {
			
			gradientLayer?.colors = [gradientColor1.cgColor, gradientColor2.cgColor]

		}

		
	}

}
