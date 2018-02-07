//
//  UIBarButtonItem+View.swift
//  TabView
//
//  Created by Ian McDowell on 2/2/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    /// Takes a UIBarButtonItem and converts it to a UIBarButtonItemView, or instead returns its custom view if it has one.
    func toView() -> UIView {
        if let customView = self.customView {
            return customView
        }

        return UIBarButtonItemView(item: self)
    }
}

/// Class that attempts to properly render a UIBarButtonItem in a UIButton.
/// Supports:
///  - title
///  - style
///  - image
/// Doesn't support:
///  - system icons
private class UIBarButtonItemView: UIButton {
    var item: UIBarButtonItem?
    private var itemObservation: NSKeyValueObservation?

    convenience init(item: UIBarButtonItem) {
        self.init(type: .system)
        self.item = item
        self.imageView?.contentMode = .scaleAspectFit
        setTitle(item.title, for: .normal)
        setImage(item.image, for: .normal)
        if let target = item.target, let action = item.action {
            addTarget(target, action: action, for: .touchUpInside)
        }
        self.titleLabel?.font = item.style == .done ? UIFont.boldSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 17)
        itemObservation = item.observe(\.title) { [weak self] item, _ in
            self?.setTitle(item.title, for: .normal)
        }
    }
}
