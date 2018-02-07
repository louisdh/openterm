//
//  TabViewTabCollectionViewLayout.swift
//  TabView
//
//  Created by Ian McDowell on 2/5/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

/// Custom layout attributes, which pass necessary data between layout and its decoration views.
private class LayoutAttributes: UICollectionViewLayoutAttributes {
    var separatorColor: UIColor?

    override func isEqual(_ object: Any?) -> Bool {
        return separatorColor == (object as? LayoutAttributes)?.separatorColor && super.isEqual(object)
    }
}

/// Custom flow-layout-like collection view layout.
/// In regular horizontal size classes, it collapses tabs into each other, similar to Safari for iPad.
class TabViewTabCollectionViewLayout: UICollectionViewLayout {

    // Provide our own custom layout class.
    override class var layoutAttributesClass: AnyClass { return LayoutAttributes.self }

    /// Color of the separator decoration views. Set by the collectionView.
    var separatorColor: UIColor = .white {
        didSet { self.invalidateLayout() }
    }

    /// A minimum width that an item can be. Items may be squished further when they are going off screen (Regular size class)
    private let minimumItemWidth: CGFloat = 120

    /// Layout attributes for each cell, indexed by the cell index in section 0
    private var cellLayoutAttributes: [UICollectionViewLayoutAttributes] = []

    /// Layout attributes for a separator per cell.
    private var separatorLayoutAttributes: [UICollectionViewLayoutAttributes] = []

    /// The total width, determined in `prepare`
    private var totalWidth: CGFloat = 0

    /// Construct the layout attributes for each item, as well as attributes for decorators.
    override func prepare() {
        super.prepare()

        self.register(SeparatorView.self, forDecorationViewOfKind: SeparatorView.elementKind)

        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else {
            return
        }

        let collectionViewWidth = collectionView.bounds.size.width

        // Only a single section is supported.
        let numberOfItems = collectionView.numberOfItems(inSection: 0)

        // Reset old values
        cellLayoutAttributes = []
        separatorLayoutAttributes = []

        // Calculate a target item width, constrained to minimum width
        let itemWidth = max(minimumItemWidth, collectionViewWidth / CGFloat(numberOfItems))
        totalWidth = itemWidth * CGFloat(numberOfItems)
        for itemIndex in 0..<numberOfItems {
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let attributes = LayoutAttributes(forCellWith: indexPath)

            var itemPosition = itemWidth * CGFloat(itemIndex)
            let width: CGFloat

            // Calculate an offset (+/- some value) that the item should be placed, relative to its standard position
            // This method creates the parallax effect shown on iPad.
            let itemOffset = self.itemOffset(in: collectionView, itemIndex: itemIndex, itemWidth: itemWidth, numberOfItems: numberOfItems)
            itemPosition += itemOffset

            // Remove overlaps by adjusting the width, based on the position/width of the element adjacent to it.
            // If the item moved to the right, then it is on the left side of the screen.
            if itemOffset > 0 {
                // Get the offset of the item to the right of this one, and wherever its leftmost point is (position + offset),
                // our width is the difference between that position and ours.
                let adjacentOffset = self.itemOffset(in: collectionView, itemIndex: itemIndex + 1, itemWidth: itemWidth, numberOfItems: numberOfItems)
                let adjacentPosition = itemWidth * CGFloat(itemIndex + 1)
                width = (adjacentPosition + adjacentOffset) - itemPosition
            } else if itemOffset < 0 && itemIndex > 0 {
                // This item is on the right side of the screen. We want to move our position past the end of the previous item.
                // We have already calculated attributes for the item on the left (since we do this in order), so retrieve those.
                let previousAttributes = cellLayoutAttributes[itemIndex - 1]
                let positionDiff = (previousAttributes.frame.origin.x + previousAttributes.frame.size.width) - itemPosition
                itemPosition += positionDiff
                width = itemWidth - positionDiff
            } else {
                // If the item isn't being offset, then it can have the standard width.
                width = itemWidth
            }

            attributes.frame = CGRect(
                x: itemPosition,
                y: 0,
                width: width,
                height: collectionView.bounds.size.height
            )

            // The first item should be on top, so the z-index is the opposite of the index of the item.
            attributes.zIndex = numberOfItems - itemIndex

            cellLayoutAttributes.append(attributes)

            // Create a separator, right off the left side of the cell. It's 0.5px wide, and offset by -0.5px
            let separatorAttributes = LayoutAttributes.init(forDecorationViewOfKind: SeparatorView.elementKind, with: indexPath)
            separatorAttributes.separatorColor = self.separatorColor
            separatorAttributes.frame = CGRect(
                x: itemPosition - 0.5,
                y: 0,
                width: 0.5,
                height: collectionView.bounds.size.height
            )
            separatorAttributes.zIndex = numberOfItems + 1

            separatorLayoutAttributes.append(separatorAttributes)
        }
    }

    /// Calculate an offset for an item relative to its original position.
    /// This offset will create a parallax-y overlay effect, similar to that in Safari for iPad.
    private func itemOffset(in collectionView: UICollectionView, itemIndex: Int, itemWidth: CGFloat, numberOfItems: Int) -> CGFloat {
        // Disable this offset logic on iPhone
        if collectionView.traitCollection.horizontalSizeClass != .regular { return 0 }

        let collectionViewWidth = collectionView.bounds.size.width

        // Define a portion of the width of the collection view that will be squished. Applies to both sides.
        let overlapDistance = collectionViewWidth / 8

        // Get current scroll position. (will be from 0...contentSize.width - collectionViewWidth)
        let currentOffset = collectionView.contentOffset.x
        // Get current scroll position on the right side (will be from collectionViewWidth...contentSize.width)
        let currentRightOffset = currentOffset + collectionViewWidth

        /// Where (in pixels) is the item that we're calculating the offset for?
        let itemPosition = itemWidth * CGFloat(itemIndex)
        /// Where (in pixels) is the right border of the item?
        let itemRightPosition = itemPosition + itemWidth

        let itemOffset: CGFloat

        // Core logic:
        // Calculate the number of squished items that are in this area, then calculate the item's position in that area.
        // The offset will be between the zero position and the overlap distance, based on the item's position

        // Is the item to the left of the left overlap point?
        if currentOffset > itemPosition - overlapDistance {
            // Position for the item to be stuck all the way to the left of the collection view
            let zeroPosition = currentOffset - itemPosition

            let numberOfSquishedItems = ((currentOffset + overlapDistance) / itemWidth)
            if numberOfSquishedItems == 0 || itemIndex == 0 {
                itemOffset = max(zeroPosition, 0)
            } else {
                let multiplier = (CGFloat(itemIndex) / numberOfSquishedItems)
                itemOffset = zeroPosition + (overlapDistance * multiplier)
            }
        }
        // Is the item to the right of the right overlap point?
        else if itemRightPosition + overlapDistance > currentRightOffset {
            // Position for the item to be stuck all the way to the right of the collection view
            let rightPosition = currentRightOffset - itemRightPosition

            let numberOfSquishedItems = (totalWidth - (currentRightOffset - overlapDistance)) / itemWidth
            if numberOfSquishedItems == 0 || itemIndex == numberOfItems - 1 {
                itemOffset = min(rightPosition, 0)
            } else {
                let multiplier = (CGFloat((numberOfItems - 1) - itemIndex) / numberOfSquishedItems)
                itemOffset = rightPosition - (overlapDistance  * multiplier)
            }
        } else {
            itemOffset = 0
        }
        return itemOffset
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override var collectionViewContentSize: CGSize {
        return CGSize.init(width: totalWidth, height: collectionView?.frame.size.height ?? 0)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellLayoutAttributes[indexPath.item]
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case SeparatorView.elementKind:
            if indexPath.item < separatorLayoutAttributes.count {
                return separatorLayoutAttributes[indexPath.item]
            }
            return UICollectionViewLayoutAttributes.init(forDecorationViewOfKind: elementKind, with: indexPath)
        default:
            return nil
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return (cellLayoutAttributes + separatorLayoutAttributes).filter { rect.intersects($0.frame) }
    }

    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        attributes.frame.size.width = minimumItemWidth
        return attributes
    }

    override func indexPathsToDeleteForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        switch elementKind {
        case SeparatorView.elementKind:
            return separatorLayoutAttributes.map { $0.indexPath }
        default:
            return []
        }
    }

}

extension TabViewTabCollectionViewLayout {

    class SeparatorView: UICollectionReusableView {

        static let elementKind: String = "SeparatorView"

        override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
            if let attributes = layoutAttributes as? LayoutAttributes {
                self.backgroundColor = attributes.separatorColor
            }
        }
    }
}

