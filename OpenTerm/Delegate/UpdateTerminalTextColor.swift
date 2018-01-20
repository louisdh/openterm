//
//  UpdateTerminalTextColor.swift
//  Terminal
//
//  Created by Simon Andersson on 2018-01-13.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class UpdateTerminalTextColor: ColorPickerViewControllerDelegate {
    
    func didSelectColor(color: UIColor) {
        UserDefaults.standard.set(color: color, forKey: "terminalTextColor")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appearanceDidChange"), object: nil)
    }
    
}
