//
//  NSNumberWrapper.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

@propertyWrapper struct NSNumberWrapped<T, N: NSNumberWrappable> {
	var path: WritableKeyPath<T, NSNumber?>
	var owner: T?
	
	var wrappedValue: N? {
		get {
			guard let number = owner?[keyPath: path] else { return nil }
			return N(nsNumber: number)
		}
		set {
			owner?[keyPath: path] = newValue?.nsNumber
		}
	}
	
	mutating func configure(with owner: T) {
		self.owner = owner
	}
	
	init(owner: T?, path: WritableKeyPath<T, NSNumber?>) {
		self.owner = owner
		self.path = path
	}
}

protocol NSNumberWrappable {
	init(nsNumber: NSNumber)
	
	var nsNumber: NSNumber { get }
}

extension Int: NSNumberWrappable {
	init(nsNumber: NSNumber) {
		self = nsNumber.intValue
	}
	
	var nsNumber: NSNumber { return NSNumber(integerLiteral: self) }
}
