//
//  ColorDisplayView.swift
//  Terminal
//
//  Created by Simon Andersson on 2018-01-14.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class ColorDisplayView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }

}
