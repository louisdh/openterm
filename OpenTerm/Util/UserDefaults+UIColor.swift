//
//  UserDefaults+UIColor.swift
//  OpenTerm
//
//  Created by Simon Andersson on 2018-01-13.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

extension UserDefaults {
	
    func set(_ color: UIColor?, forKey defaultName: String) {
        guard let value = color else {
			set(Optional<Any>.none, forKey: defaultName)
            return
        }
		
		let data = NSKeyedArchiver.archivedData(withRootObject: value)
        set(data, forKey: defaultName)
    }
    
    func color(forKey defaultName: String) -> UIColor? {
        guard let data = data(forKey: defaultName) else {
			return nil
		}
		
		guard let color = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor else {
			return nil
		}
		
        return color
    }
	
}
