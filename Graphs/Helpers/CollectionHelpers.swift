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
