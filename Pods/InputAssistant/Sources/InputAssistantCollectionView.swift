//
//  InputAssistantCollectionView.swift
//  InputAssistant
//
//  Created by Ian McDowell on 1/28/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

class InputAssistantCollectionView: UICollectionView {
    
    /// Reference to the containing input assistant view
    weak var inputAssistantView: InputAssistantView?
    
    /// Width constraint that equals the contentSize.width of the collection view. Low priority.
    var widthConstraint: NSLayoutConstraint?
    
    /// Label to display when there are no suggestions
    private let noSuggestionsLabel = UILabel()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 41)
        layout.itemSize = UICollectionViewFlowLayoutAutomaticSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        super.init(frame: .zero, collectionViewLayout: layout)

        register(InputAssistantCollectionViewCell.self, forCellWithReuseIdentifier: "Suggestion")
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        dataSource = self
        
        noSuggestionsLabel.textAlignment = .center
        noSuggestionsLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noSuggestionsLabel.textColor = UIColor.darkGray
        addSubview(noSuggestionsLabel)
        
        widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint?.priority = .defaultLow
        widthConstraint?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func reloadData() {
        super.reloadData()

        // Need to reset scrolling position,
        // since the self sizing cells can cause a crash when scrolling back after a reloadData.
        contentOffset = .zero
		
        noSuggestionsLabel.text = self.inputAssistantView?.dataSource?.textForEmptySuggestionsInInputAssistantView()
        noSuggestionsLabel.isHidden = self.numberOfItems(inSection: 0) > 0
    }
    
    override var contentSize: CGSize {
        didSet {
            // If there is no data, make the width the width of the no suggestions label.
            // Otherwise, it should be equal to the content size of the collectionView
            if !noSuggestionsLabel.isHidden {
                let targetLabelSize = noSuggestionsLabel.systemLayoutSizeFitting(CGSize(width: 9999, height: 55))
                widthConstraint?.constant = targetLabelSize.width
            } else {
                widthConstraint?.constant = contentSize.width
            }
        }
    }
}

extension InputAssistantCollectionView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputAssistantView?.dataSource?.numberOfSuggestionsInInputAssistantView() ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Suggestion", for: indexPath) as! InputAssistantCollectionViewCell
        
        guard let inputAssistantView = inputAssistantView, let name = inputAssistantView.dataSource?.inputAssistantView(inputAssistantView, nameForSuggestionAtIndex: indexPath.row) else {
            fatalError("No suggestion name found at index.")
        }

        cell.label.text = name
        cell.keyboardAppearance = inputAssistantView.keyboardAppearance
        
        return cell
    }
}

private class InputAssistantCollectionViewCell: UICollectionViewCell {
    
    let label: UILabel
    let highlightedBackgroundColor = UIColor(red: 235/255, green: 237/255, blue: 239/255, alpha: 1)
    let regularBackgroundColor = UIColor(red: 174/255, green: 180/255, blue: 186/255, alpha: 1)
    let darkBackgroundColor = UIColor(white: 200/255, alpha: 0.4)

    var keyboardAppearance: UIKeyboardAppearance = .default {
        didSet { updateSelectionState() }
    }

    private var keyboardAppearanceBackgroundColor: UIColor {
        switch keyboardAppearance {
        case .dark: return self.darkBackgroundColor
        default: return self.regularBackgroundColor
        }
    }
    
    override init(frame: CGRect) {
        label = UILabel()
        
        super.init(frame: frame)

        label.textAlignment = .center
        
        self.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        updateSelectionState()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var isHighlighted: Bool {
        didSet { updateSelectionState() }
    }
    override var isSelected: Bool {
        didSet { updateSelectionState() }
    }
    
    private func updateSelectionState() {
        let isHighlighted = self.isHighlighted || self.isSelected
        self.backgroundColor = isHighlighted ? self.highlightedBackgroundColor : self.keyboardAppearanceBackgroundColor
        self.label.textColor = isHighlighted ? .black : .white
    }
}
