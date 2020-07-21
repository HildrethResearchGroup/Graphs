//
//  CollectionHelpers.swift
//  Graphs
//
//  Created by Connor Barnes on 7/17/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

extension RandomAccessCollection where Element: RandomAccessCollection, Index == Int, Element.Index == Int {
	func columns(count numberOfColumns: Int) -> [[Element.Element?]] {
		return (0..<numberOfColumns).map { columnIndex in
			return (0..<self.count).map { rowIndex in
				return columnIndex < self[rowIndex].count ? self[rowIndex][columnIndex] : nil
			}
		}
	}
}

extension Collection where Element: Hashable, Index == Int {
	// This function was written to find the indicies of m elements in a collection of n elements in O(n+m) time. Calling firstIndex(of:) repeatedly instead is O(n*m)
	/// Returns the indicies of the given elements in the collection.
	/// - Parameter elements: The elements to find the indicies of.
	/// - Returns: The indicies of the given elements.
	func indicies(of elements: [Element]) -> IndexSet {
		let elementSet = Set(elements)
		var indicies = IndexSet()
		var index = startIndex
		// Iterate over the collection
		var iterator = makeIterator()
		while let element = iterator.next() {
			if elementSet.contains(element) {
				indicies.insert(index)
			}
			// Increment the current index
			index = self.index(after: index)
		}
		
		return indicies
	}
}
