//
//  UpdateTerminalBackgroundColor.swift
//  OpenTerm
//
//  Created by Simon Andersson on 2018-01-14.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class UpdateTerminalBackgroundColor: ColorPickerViewControllerDelegate {
    
    func didSelectColor(color: UIColor) {
        UserDefaults.standard.set(color: color, forKey: "terminalBackgroundColor")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appearanceDidChange"), object: nil)
    }
    
}
