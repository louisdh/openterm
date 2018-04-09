//
//  UICollectionView+Update.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 06/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionView {
	
}

extension CollectionView {
	
	typealias MoveItemClosure = (_ from: IndexPath, _ to: IndexPath) -> Void
	typealias DeleteItemClosure = (_ at: IndexPath) -> Void
	typealias InsertItemClosure = (_ at: IndexPath) -> Void
	typealias SameIdentityClosure<T> = (T, T) -> Bool
	typealias SameValueClosure<T> = (T, T) -> Bool

	public func update<T>(section: Int, from oldElements: [T], to newElements: [T], onMoveItem: MoveItemClosure, onDeleteItem: DeleteItemClosure, onInsertItem: InsertItemClosure, sameIdentityClosure: SameIdentityClosure<T>, sameValueClosure: SameValueClosure<T>) {
		
		if oldElements.elementsEqual(newElements, by: { sameValueClosure($0, $1) }) {
			return
		}
		
		for i in 0..<max(oldElements.count, newElements.count) {
			
			let indexPath = IndexPath(item: i, section: section)
			
			let prevElement: T?
			let newElement: T?
			
			if i < oldElements.count {
				prevElement = oldElements[i]
			} else {
				prevElement = nil
			}
			
			if i < newElements.count {
				newElement = newElements[i]
			} else {
				newElement = nil
			}
			
			if let prevElement = prevElement {
				
				// if prev element still exists: move
				if let newRow = newElements.index(where: { sameIdentityClosure(prevElement, $0) }) {
					let indexPathTo = IndexPath(item: newRow, section: section)
					
					if indexPath != indexPathTo {
						onMoveItem(indexPath, indexPathTo)
					}
					
				}
				
				// if prev element does not exist in new: delete
				if !newElements.contains(where: { sameIdentityClosure(prevElement, $0) }) {
					onDeleteItem(indexPath)
				}
				
			}
			
			if let newElement = newElement {
				
				// if element does not exist in prev: insert
				if !oldElements.contains(where: { sameIdentityClosure(newElement, $0) }) {
					onInsertItem(indexPath)
				}
				
			}
			
		}
		
	}
	
}

extension UICollectionView: CollectionView {
	
	/// In order to reliable use this update mechanism, make sure every element (in
	/// oldElements and newElements) is unique. Meaning the `sameIdentityClosure` will not
	/// return true for 2 different elements in the `oldElements` and `newElements` arrays.
	///
	/// - Parameters:
	///   - section: The section to update.
	///   - oldElements: The elements in the collection view before the update.
	///   - newElements: The elements in the collection view after the update.
	func update<T>(dataSourceUpdateClosure: () -> Void, section: Int, from oldElements: [T], to newElements: [T], sameIdentityClosure: SameIdentityClosure<T>, sameValueClosure: SameValueClosure<T>) {
		
		self.performBatchUpdates({

			dataSourceUpdateClosure()
			
			update(section: section, from: oldElements, to: newElements, onMoveItem: { (atIndexPath, toIndexPath) in
				
				self.moveItem(at: atIndexPath, to: toIndexPath)
				
			}, onDeleteItem: { (indexPath) in
				
				self.deleteItems(at: [indexPath])
				
			}, onInsertItem: { (indexPath) in
				
				self.insertItems(at: [indexPath])
				
			}, sameIdentityClosure: sameIdentityClosure, sameValueClosure: sameValueClosure)
			
		})
		
		self.performBatchUpdates({

			for (i, element) in newElements.enumerated() {
				
				let indexPath = IndexPath(item: i, section: section)
				
				if let oldI = oldElements.index(where: { sameIdentityClosure($0, element) }) {
					
					if !sameValueClosure(oldElements[oldI], element) {
						self.reloadItems(at: [indexPath])
					}
					
				}
				
			}
			
		})
			
	}
	
}

extension UITableView: CollectionView {

	/// Make sure to call `beginUpdates()` before calling this, and `endUpdates()` after.
	///
	/// In order to reliable use this update mechanism, make sure every element (in
	/// oldElements and newElements) is unique. Meaning the `Equatable` conformance will not
	/// return true for 2 different elements in the `oldElements` and `newElements` arrays.
	///
	/// - Parameters:
	///   - section: The section to update.
	///   - oldElements: The elements in the table view before the update.
	///   - newElements: The elements in the table view after the update.
	///   - animation: Row animation to use. Default is `automatic`.
	func update<T: Equatable>(section: Int, from oldElements: [T], to newElements: [T], animation: UITableViewRowAnimation = .automatic) {

		update(section: section, from: oldElements, to: newElements, onMoveItem: { (atIndexPath, toIndexPath) in

			self.moveRow(at: atIndexPath, to: toIndexPath)

		}, onDeleteItem: { (indexPath) in

			self.deleteRows(at: [indexPath], with: animation)

		}, onInsertItem: { (indexPath) in

			self.insertRows(at: [indexPath], with: animation)

		}, sameIdentityClosure: { (v1, v2) -> Bool in
			
			return v1 == v2
			
		}, sameValueClosure: { (v1, v2) -> Bool in
			
			return v1 == v2
			
		})

	}

}
