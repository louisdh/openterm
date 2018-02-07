//
//  NSLayoutConstraint+Custom.swift
//  TabView
//
//  Created by Ian McDowell on 2/2/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

public extension NSLayoutConstraint {

    /// Add a priority to an existing constraint.
    /// Useful when creating and setting at the same time:
    ///    self.constraint = self.widthAnchor.constraint(equalToConstant: 0).withPriority(.defaultHigh)
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
