//
//  UserDefaults+UIColor.swift
//  OpenTerm
//
//  Created by Simon Andersson on 2018-01-13.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

extension UserDefaults {
    func set(color: UIColor?, forKey: String) {
        guard let value = color else {
            set(nil, forKey: forKey)
            return
        }
        set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: forKey)
    }
    
    func colorForKey(forKey: String) -> UIColor? {
        guard let data = data(forKey: forKey), let color = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
        else { return nil }
        return color
    }
}
