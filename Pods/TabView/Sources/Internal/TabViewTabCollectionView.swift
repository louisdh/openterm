//
//  TabViewTabCollectionView.swift
//  TabView
//
//  Created by Ian McDowell on 2/2/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

private let closeButtonSize: CGFloat = 28
private let closeButtonImageSize: CGFloat = 15
private let closeButtonImagePadding: CGFloat = 4
private let closeButtonImageThickness: CGFloat = 1
private let minimumTabWidth: CGFloat = 125
private let titleLabelPadding: CGFloat = 8

/// Collection view to display a horizontal list of tabs.
class TabViewTabCollectionView: UICollectionView {

    /// The bar that the collection view is inside.
    weak var bar: TabViewBar?

    private var barDataSource: TabViewBarDataSource? { return bar?.barDataSource }
    private var barDelegate: TabViewBarDelegate? { return bar?.barDelegate }

    private let layout: UICollectionViewFlowLayout

    var theme: TabViewTheme {
        didSet { applyTheme(theme) }
    }

    init(theme: TabViewTheme) {
        self.layout = TabViewTabCollectionViewLayout()
        self.theme = theme

        super.init(frame: .zero, collectionViewLayout: layout)

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero

        self.backgroundColor = nil
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.allowsMultipleSelection = false

        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gesture:))))

        self.register(TabViewTab.self, forCellWithReuseIdentifier: "Tab")

        self.delegate = self
        self.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Calls `update` for each visible cell.
    /// Useful to update title and such without affecting selection state
    func updateVisibleTabs() {
        for cell in self.visibleCells.flatMap({ $0 as? TabViewTab }) {
            cell.update()
        }
    }

    /// Apply the given theme to the view
    private func applyTheme(_ theme: TabViewTheme) {
        updateVisibleTabs()
    }

    private var viewControllers: [UIViewController] {
        return barDataSource?.viewControllers ?? []
    }

}
extension TabViewTabCollectionView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab", for: indexPath) as! TabViewTab
        let tab = viewControllers[indexPath.row]

        cell.collectionView = self
        cell.setTab(tab)

        return cell
    }
}
extension TabViewTabCollectionView: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = viewControllers[indexPath.row]

        barDelegate?.activateTab(viewController)
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Allow for reordering tabs

        barDelegate?.swapTab(atIndex: sourceIndexPath.row, withTabAtIndex: destinationIndexPath.row)
    }

}
extension TabViewTabCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvHeight = collectionView.frame.size.height
        let cvWidth = collectionView.frame.size.width

        let numVCs = CGFloat(viewControllers.count)

        return CGSize(width: max(minimumTabWidth, cvWidth / numVCs), height: cvHeight)
    }
}
// MARK: Long press gesture
extension TabViewTabCollectionView {

    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {

        case .began:
            guard let selectedIndexPath = self.indexPathForItem(at: gesture.location(in: self)) else {
                break
            }
            self.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            var location = gesture.location(in: gesture.view!)
            location.y = gesture.view!.bounds.size.height / 2
            self.updateInteractiveMovementTargetPosition(location)
        case .ended:
            self.endInteractiveMovement()
        default:
            self.cancelInteractiveMovement()
        }
    }
}

private class TabViewTab: UICollectionViewCell {

    private let leftSeparatorView: UIView
    private let titleView: UILabel
    private let closeButton: UIButton

    private weak var currentTab: UIViewController?
    weak var collectionView: TabViewTabCollectionView?

    override var isSelected: Bool {
        didSet { update() }
    }

    override init(frame: CGRect) {
        leftSeparatorView = UIView()
        closeButton = UIButton()
        titleView = UILabel()

        super.init(frame: frame)

        leftSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftSeparatorView)
        NSLayoutConstraint.activate([
            leftSeparatorView.widthAnchor.constraint(equalToConstant: 0.5),
            leftSeparatorView.rightAnchor.constraint(equalTo: leftAnchor),
            leftSeparatorView.topAnchor.constraint(equalTo: topAnchor),
            leftSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let buttonSize = CGSize(width: closeButtonSize, height: closeButtonSize)
        let buttonImageSize = CGSize(width: closeButtonImageSize, height: closeButtonImageSize)
        let buttonSizeDiff = CGSize(width: buttonSize.width - buttonImageSize.width, height: buttonSize.height - buttonImageSize.height)
        let buttonInsets = UIEdgeInsets(top: buttonSizeDiff.height / 2, left: buttonSizeDiff.width / 2, bottom: buttonSizeDiff.height / 2, right: buttonSizeDiff.width / 2)

        closeButton.setImage(TabViewTab.closeImage, for: .normal)
        closeButton.imageView?.layer.cornerRadius = buttonImageSize.width / 2
        closeButton.imageEdgeInsets = buttonInsets

        closeButton.addTarget(self, action: #selector(TabViewTab.closeButtonTapped), for: .touchUpInside)

        titleView.textAlignment = .center
        titleView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(closeButton)
        contentView.addSubview(titleView)

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize.width).withPriority(.defaultHigh),
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize.height).withPriority(.defaultHigh)
        ])
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme(_ theme: TabViewTheme) {

        closeButton.imageView?.tintColor = theme.tabCloseButtonColor
        closeButton.imageView?.backgroundColor = theme.tabCloseButtonBackgroundColor

        if self.isSelected {
            self.leftSeparatorView.backgroundColor = nil
            self.backgroundColor = nil
            self.closeButton.isHidden = false
            titleView.textColor = theme.tabSelectedTextColor
        } else {
            self.leftSeparatorView.backgroundColor = theme.separatorColor
            self.backgroundColor = theme.tabBackgroundDeselectedColor
            self.closeButton.isHidden = true
            titleView.textColor = theme.tabTextColor
        }
    }

    func setTab(_ tab: UIViewController) {
        currentTab = tab

        update()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleView.text = nil
    }

    func update() {
        if let theme = collectionView?.theme {
            applyTheme(theme)
        }

        if !closeButton.isHidden && self.bounds.width - titleView.intrinsicContentSize.width < closeButtonSize {
            titleView.text = "\t" + (currentTab?.title ?? "")
        } else {
            titleView.text = currentTab?.title
        }
    }

    @objc func closeButtonTapped() {
        if let currentTab = currentTab {
            collectionView?.bar?.barDelegate?.closeTab(currentTab)
        }
    }

    private static var closeImage: UIImage = {
        let size = CGSize(width: closeButtonImageSize, height: closeButtonImageSize)
        let start = closeButtonImagePadding
        let finish = size.width - closeButtonImagePadding
        let thickness = closeButtonImageThickness
        return UIGraphicsImageRenderer(size: size).image(actions: { context in
            let downwards = UIBezierPath()
            downwards.move(to: CGPoint(x: start, y: start))
            downwards.addLine(to: CGPoint(x: finish, y: finish))
            UIColor.white.setStroke()
            downwards.lineWidth = thickness
            downwards.stroke()

            let upwards = UIBezierPath()
            upwards.move(to: CGPoint(x: start, y: finish))
            upwards.addLine(to: CGPoint(x: finish, y: start))
            UIColor.white.setStroke()
            upwards.lineWidth = thickness
            upwards.stroke()

            context.cgContext.addPath(downwards.cgPath)
            context.cgContext.addPath(upwards.cgPath)
        }).withRenderingMode(.alwaysTemplate)
    }()
}

private class TabViewTabCollectionViewLayout: UICollectionViewFlowLayout {

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
