//
//  CollectionHelpers.swift
//  Graphs
//
//  Created by Connor Barnes on 7/17/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

extension RandomAccessCollection where Element: RandomAccessCollection, Index == Int, Element.Index == Int {
	/// Returns the columns of the two dimensional collection.
	///
	/// If the collection has rows with fewer elements that `numberOfColumns`, then elements for that column will be `nil`.
	///
	/// **Example**
	///
	/// In the following example, a 2D array is transformed into columns:
	///
	/// ```
	/// let array = [[1, 2, 3],
	///              [4, 5, 6],
	///              [7, 8, 9, 10]]
	/// let columns = array.columns(count: 4)
	/// /*
	/// columns = [[1, 4, 7],
	///            [2, 5, 8],
	///            [3, 6, 9],
	///            [nil, nil, 10]]
	/// */
	/// ```
	///
	/// - Parameter numberOfColumns: The number of columns in the collection to return.
	/// - Returns: The columns of the two dimensional collection.
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

extension Sequence {
	/// Returns a boolean value indicating if none of the elements of a sequence satisfy the given predicate.
	/// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element satisfies a condition.
	/// - Returns: `true` if the sequence contains no elements that satisfy `predicate`; otherwise, `false`.
	public func noneSatisfy(_ predicate: (Self.Element) throws -> Bool) rethrows -> Bool {
		return try allSatisfy { try !predicate($0) }
	}
}