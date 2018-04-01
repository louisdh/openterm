//
//  PridelandCollectionViewCell.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 01/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class PridelandCollectionViewCell: UICollectionViewCell {

	let gradientLayer = CAGradientLayer()

	@IBOutlet weak var titleLbl: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()

		gradientLayer.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
		gradientLayer.startPoint = .zero
		gradientLayer.endPoint = CGPoint(x: 1, y: 1)
		
		self.contentView.layer.insertSublayer(gradientLayer, at: 0)
	
		self.contentView.layer.cornerRadius = 16.0
		self.contentView.layer.masksToBounds = true
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		gradientLayer.frame = self.contentView.bounds

	}
	
	func show(_ prideland: String) {
		
		titleLbl.text = prideland
		
		updateGradient()
		
	}
	
	private func updateGradient() {
		
		guard let gradientColor1 = UIColor(hexString: "#ff6c3f") else {
			return
		}
		
		guard let gradientColor2 = UIColor(hexString: "#ff2400") else {
			return
		}
		
		gradientLayer.colors = [gradientColor1.cgColor, gradientColor2.cgColor]
		
	}

}
