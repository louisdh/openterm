//
//  InputAssistantView.swift
//  InputAssistant
//
//  Created by Ian McDowell on 1/28/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

/// A button to be displayed in on the leading or trailing side of an input assistant.
public struct InputAssistantAction {
    
    /// Image to display to the user. Will be resized to fit the height of the input assistant.
    public let image: UIImage
    
    public weak var target: AnyObject?
    public let action: Selector?
    
    public init(image: UIImage, target: AnyObject? = nil, action: Selector? = nil) {
        self.image = image; self.target = target; self.action = action
    }
}

public protocol InputAssistantViewDataSource: class {
    
    /// Text to display when there are no suggestions.
    func textForEmptySuggestionsInInputAssistantView() -> String?
    
    /// Number of suggestions to display
    func numberOfSuggestionsInInputAssistantView() -> Int
    
    /// Return information about the suggestion at the given index
    func inputAssistantView(_ inputAssistantView: InputAssistantView, nameForSuggestionAtIndex index: Int) -> String
}

/// Delegate to receive notifications about user actions in the input assistant view.
public protocol InputAssistantViewDelegate: class {
    
    /// When the user taps on a suggestion
    func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int)
}

/// UIInputView that displays custom suggestions, as well as leading and trailing actions.
open class InputAssistantView: UIInputView {
    
    /// Actions to display on the leading side of the suggestions.
    public var leadingActions: [InputAssistantAction] = [] {
        didSet { self.updateActions(leadingActions, leadingStackView) }
    }
    
    /// Actions to display on the trailing side of the suggestions
    public var trailingActions: [InputAssistantAction] = [] {
        didSet { self.updateActions(trailingActions, trailingStackView) }
    }
    
    /// Set this to receive notifications when things happen in the assistant view.
    public weak var delegate: InputAssistantViewDelegate?
    
    /// Set this to provide data to the input assistant view
    public weak var dataSource: InputAssistantViewDataSource? {
        didSet { suggestionsCollectionView.reloadData() }
    }
    
    /// Stack view on the leading side of the collection view. Contains actions.
    private let leadingStackView: UIStackView
    
    /// Stack view on the trailing side of the collection view. Contains actions.
    private let trailingStackView: UIStackView
    
    /// Collection view, with a horizontally scrolling set of suggestions.
    private let suggestionsCollectionView: InputAssistantCollectionView
    
    public init() {
        self.leadingStackView = UIStackView()
        self.trailingStackView = UIStackView()
        
        self.suggestionsCollectionView = InputAssistantCollectionView()
        
        super.init(frame: .init(origin: .zero, size: .init(width: 0, height: 55)), inputViewStyle: .default)
        
        self.suggestionsCollectionView.inputAssistantView = self
        self.suggestionsCollectionView.delegate = self
        
        for stackView in [leadingStackView, trailingStackView] {
            stackView.spacing = 10
            stackView.alignment = .center
            stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            updateActions([], stackView)
        }

        // suggestions stretch to fill
        suggestionsCollectionView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // The stack views are embedded into a container, which lays them out horizontally
        let containerStackView = UIStackView(arrangedSubviews: [leadingStackView, suggestionsCollectionView, trailingStackView])
        containerStackView.alignment = .fill
        containerStackView.axis = .horizontal
        containerStackView.distribution = .equalCentering

        // Stretch to fill bounds
        containerStackView.frame = self.bounds
        self.addSubview(containerStackView)
        containerStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public func reloadData() {
        suggestionsCollectionView.reloadData()
    }

    /// The keyboard appearance of the attached text input
    internal var keyboardAppearance: UIKeyboardAppearance = .default {
        didSet {
            switch keyboardAppearance {
            case .dark: self.tintColor = .white
            default: self.tintColor = .black
            }
        }
    }
    private var keyboardAppearanceObserver: NSKeyValueObservation?

    /// Attach the inputAssistant to the given UITextView.
    public func attach(to textInput: UITextView) {
        self.keyboardAppearance = textInput.keyboardAppearance

        // Hide default undo/redo/etc buttons
        textInput.inputAssistantItem.leadingBarButtonGroups = []
        textInput.inputAssistantItem.trailingBarButtonGroups = []

        // Disable built-in autocomplete
        textInput.autocorrectionType = .no

        // Add the input assistant view as an accessory view
        textInput.inputAccessoryView = self

        keyboardAppearanceObserver = textInput.observe(\UITextView.keyboardAppearance) { [weak self] textInput, _ in
            self?.keyboardAppearance = textInput.keyboardAppearance
        }
    }
    /// Attach the inputAssistant to the given UITextView.
    public func attach(to textInput: UITextField) {
        self.keyboardAppearance = textInput.keyboardAppearance

        // Hide default undo/redo/etc buttons
        textInput.inputAssistantItem.leadingBarButtonGroups = []
        textInput.inputAssistantItem.trailingBarButtonGroups = []

        // Disable built-in autocomplete
        textInput.autocorrectionType = .no

        // Add the input assistant view as an accessory view
        textInput.inputAccessoryView = self

        keyboardAppearanceObserver = textInput.observe(\UITextField.keyboardAppearance) { [weak self] textInput, _ in
            self?.keyboardAppearance = textInput.keyboardAppearance
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateActions(leadingActions, leadingStackView)
        updateActions(trailingActions, trailingStackView)
    }
    
    /// Remove existing actions, and add new ones to the given leading/trailing stack view.
    private func updateActions(_ actions: [InputAssistantAction], _ stackView: UIStackView) {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        if actions.isEmpty {
            let emptyView = UIView()
            emptyView.widthAnchor.constraint(equalToConstant: 0).isActive = true
            stackView.addArrangedSubview(emptyView)
        } else {
            let itemWidth: CGFloat = self.traitCollection.horizontalSizeClass == .regular ? 60 : 40
            for action in actions {
                let button = UIButton.init(type: .system)
                button.setImage(action.image.scaled(toSize: CGSize(width: 25, height: 25)), for: .normal)
                if let target = action.target, let action = action.action {
                    button.addTarget(target, action: action, for: .touchUpInside)
                }

                // If possible, the button should be at least 40px wide for a good sized tap target

                let widthConstraint = button.widthAnchor.constraint(equalToConstant: itemWidth)
                widthConstraint.priority = .defaultHigh
                widthConstraint.isActive = true
                
                stackView.addArrangedSubview(button)
            }
        }
    }
}

extension UIImage {
    
    /// Scales the image to the given CGSize
    func scaled(toSize size: CGSize) -> UIImage {
        if self.size == size {
            return self
        }
        
        let newImage = UIGraphicsImageRenderer(size: size).image { context in
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return newImage.withRenderingMode(self.renderingMode)
    }
}

extension InputAssistantView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIDevice.current.playInputClick()
        collectionView.deselectItem(at: indexPath, animated: true)
        
        self.delegate?.inputAssistantView(self, didSelectSuggestionAtIndex: indexPath.row)
    }
}

extension InputAssistantView: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool { return true }
}

