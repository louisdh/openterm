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
private let titleLabelPadding: CGFloat = 12

/// Collection view to display a horizontal list of tabs.
class TabViewTabCollectionView: UICollectionView {

    /// The bar that the collection view is inside.
    weak var bar: TabViewBar?

    private var barDataSource: TabViewBarDataSource? { return bar?.barDataSource }
    private var barDelegate: TabViewBarDelegate? { return bar?.barDelegate }

    var theme: TabViewTheme {
        didSet { applyTheme(theme) }
    }

    init(theme: TabViewTheme) {
        self.theme = theme

        super.init(frame: .zero, collectionViewLayout: TabViewTabCollectionViewLayout())

        self.backgroundColor = nil
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.allowsMultipleSelection = false

        // Enable drag and drop
        self.dragInteractionEnabled = true

        self.register(TabViewTab.self, forCellWithReuseIdentifier: "Tab")

        self.delegate = self
        self.dataSource = self
        self.dragDelegate = self
        self.dropDelegate = self

        applyTheme(theme)
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
        (self.collectionViewLayout as? TabViewTabCollectionViewLayout)?.separatorColor = theme.separatorColor
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

}

extension TabViewTabCollectionView: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        barDelegate?.dragInProgress = true
        session.localContext = self.barDelegate
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        barDelegate?.dragInProgress = false
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem.init(itemProvider: NSItemProvider.init())
        dragItem.localObject = viewControllers[indexPath.item]

        // Render the cell in the given size, so even if it is shrunk (on iPad), it will be a reasonable size.
        let size = CGSize.init(width: 120, height: collectionView.bounds.height)
        let snapshot = self.snapshotCell(at: indexPath, withSize: size)

        // Put the snapshot in an image view and give it to the drag item for previewing
        let imageView = UIImageView(image: snapshot)
        let parameters = self.collectionView(collectionView, dragPreviewParametersForItemAt: indexPath)!
        dragItem.previewProvider = { return UIDragPreview.init(view: imageView, parameters: parameters) }
        return [
            dragItem
        ]
    }

    private func snapshotCell(at indexPath: IndexPath, withSize size: CGSize) -> UIImage {
        guard let view = cellForItem(at: indexPath) else { return UIImage() }
        let frame = view.frame
        view.frame = CGRect.init(origin: .zero, size: size)
        let image = UIGraphicsImageRenderer.init(size: size).image { context in
            view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        }
        view.frame = frame
        return image
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        // Since the cell may not have a background color (if it's selected), set one to the background color of the bar
        parameters.backgroundColor = theme.barTintColor
        return parameters
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        // Don't let tabs escape the current app.
        return true
    }
}

extension TabViewTabCollectionView: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        guard let localSession = session.localDragSession, let localObject = localSession.items.first?.localObject else { return false }
        let canHandle = localObject is UIViewController
        return canHandle
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal.init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard
            let dragItem = coordinator.session.localDragSession?.items.first,
            let destinationIndexPath = coordinator.destinationIndexPath,
            let viewController = dragItem.localObject as? UIViewController,
            let oldDelegate = coordinator.session.localDragSession?.localContext as? TabViewBarDelegate
        else { return }
        oldDelegate.closeTab(viewController)
        barDelegate?.insertTab(viewController, atIndex: destinationIndexPath.item)
        self.barDelegate?.activateTab(viewController)
    }
}

private class TabViewTab: UICollectionViewCell {

    private let titleView: UILabel
    private let closeButton: UIButton

    private var titleViewLeadingConstraint: NSLayoutConstraint?
    private var titleViewWidthConstraint: NSLayoutConstraint?

    private weak var currentTab: UIViewController?
    weak var collectionView: TabViewTabCollectionView?

    override var isSelected: Bool {
        didSet { update() }
    }

    override init(frame: CGRect) {
        closeButton = UIButton()
        titleView = UILabel()

        super.init(frame: frame)

        self.clipsToBounds = true

        let buttonSize = CGSize(width: closeButtonSize, height: closeButtonSize)
        let buttonImageSize = CGSize(width: closeButtonImageSize, height: closeButtonImageSize)
        let buttonSizeDiff = CGSize(width: buttonSize.width - buttonImageSize.width, height: buttonSize.height - buttonImageSize.height)
        let buttonInsets = UIEdgeInsets(top: buttonSizeDiff.height / 2, left: buttonSizeDiff.width / 2, bottom: buttonSizeDiff.height / 2, right: buttonSizeDiff.width / 2)

        closeButton.setImage(TabViewTab.closeImage, for: .normal)
        closeButton.imageView?.layer.cornerRadius = buttonImageSize.width / 2
        closeButton.imageEdgeInsets = buttonInsets

        closeButton.addTarget(self, action: #selector(TabViewTab.closeButtonTapped), for: .touchUpInside)

        titleView.textAlignment = .center
        titleView.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(closeButton)
        contentView.addSubview(titleView)

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize.width).withPriority(.defaultHigh),
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize.height).withPriority(.defaultHigh)
        ])

        let titleViewLeadingConstraint = titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabelPadding)
        let titleViewWidthConstraint = titleView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        self.titleViewLeadingConstraint = titleViewLeadingConstraint
        self.titleViewWidthConstraint = titleViewWidthConstraint
        NSLayoutConstraint.activate([
            titleViewLeadingConstraint,
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -titleLabelPadding).withPriority(.defaultHigh),
            titleViewWidthConstraint,
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Don't provide our own attributes. The default implementation calls systemLayoutSizeFittingSize, which is expensive.
        return layoutAttributes
    }

    private var isActive: Bool {
        return collectionView?.bar?.barDataSource?.visibleViewController == currentTab
    }

    func applyTheme(_ theme: TabViewTheme) {

        closeButton.imageView?.tintColor = theme.tabCloseButtonColor
        closeButton.imageView?.backgroundColor = theme.tabCloseButtonBackgroundColor

        if isActive {
            self.backgroundColor = nil
            titleView.textColor = theme.tabSelectedTextColor
        } else {
            self.backgroundColor = theme.tabBackgroundDeselectedColor
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

        self.closeButton.isHidden = !self.isActive || self.bounds.size.width < closeButtonSize

        titleView.text = self.currentTab?.title
        if !closeButton.isHidden && self.bounds.width - titleView.intrinsicContentSize.width - titleLabelPadding * 2 < closeButtonSize {
            self.titleViewLeadingConstraint?.constant = closeButtonSize
            self.titleViewWidthConstraint?.constant = 120 - (closeButtonSize + titleLabelPadding)
        } else {
            self.titleViewLeadingConstraint?.constant = titleLabelPadding
            self.titleViewWidthConstraint?.constant = 120 - titleLabelPadding * 2
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
