//
//  NSNumberWrapper.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

// Created to simplify casting optional NSNumber properties of CoreData to native Swfit types.
/// A property wrapper over optional `NSNumber` instances to cast them to native Swift types.
@propertyWrapper struct NSNumberWrapped<T, N: NSNumberWrappable> {
	/// The path of the `NSNumber` value.
	var path: WritableKeyPath<T, NSNumber?>
	/// The owner of the `NSNumber` value.
	var owner: T?
	/// A casted value from an `NSNumber` instance.
	var wrappedValue: N? {
		get {
			guard let number = owner?[keyPath: path] else { return nil }
			return N(nsNumber: number)
		}
		set {
			owner?[keyPath: path] = newValue?.nsNumber
		}
	}
	/// Configures the owner of the wrapper.
	/// - Parameter owner: The new owner of the wrapper.
	mutating func configure(with owner: T) {
		self.owner = owner
	}
	/// Creates a wrapper from an owner and a keypath of the owner's type.
	/// - Parameters:
	///   - owner: The owner of the `NSNumber` instance.
	///   - path: The path to the `NSNumber` instance.
	init(owner: T?, path: WritableKeyPath<T, NSNumber?>) {
		self.owner = owner
		self.path = path
	}
}

/// A type that can be converted to and from an `NSNumber` instance.
protocol NSNumberWrappable {
	/// Initializes the value from an instance of `NSNumber`.
	/// - Parameter nsNumber: The `NSNumber` instance to cast from.
	init(nsNumber: NSNumber)
	/// The value casted as an `NSNumber`.
	var nsNumber: NSNumber { get }
}

// MARK: Int Conformance to NSNumberWrappable
extension Int: NSNumberWrappable {
	/// Initializes an `Int` from the value of an `NSNumber`.
	/// - Parameter nsNumber: An `NSNumber` value.
	init(nsNumber: NSNumber) {
		self = nsNumber.intValue
	}
	/// The `NSNumber` representation of the integer.
	var nsNumber: NSNumber { return NSNumber(integerLiteral: self) }
}
