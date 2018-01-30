//
//  UIColor+AssetCatalog.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 06/01/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

extension UIColor {

	static var defaultMainTintColor: UIColor {
		guard let defaultMainTintColor = UIColor(named: "Main Tint Color") else {
			fatalError("Expected color, check asset catalog")
		}
		return defaultMainTintColor
	}

    static var panelBackgroundColor: UIColor {
        guard let panelBackgroundColor = UIColor(named: "Panel Background Color") else {
            fatalError("Expected color, check asset catalog")
        }
        return panelBackgroundColor
    }

}
