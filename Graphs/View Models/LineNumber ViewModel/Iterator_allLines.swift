//
//  Iterator_allLines.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/11/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation

//https://forums.developer.apple.com/forums/thread/725162

extension AsyncSequence where Element == UInt8 {
    //Works.
    var allLines:AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let bytesTask = Task {
                var accumulator:[UInt8] = []
                var iterator = self.makeAsyncIterator()
                while let byte = try await iterator.next() {
                    //10 == \n
                    if byte != 10 { accumulator.append(byte) }
                    else {
                        if accumulator.isEmpty { continuation.yield("") }
                        else {
                            if let line = String(data: Data(accumulator), encoding: .utf8) {
                                continuation.yield(line)
                            }
                            else {
                                throw StreamError.couldNotMakeString("Could not make a String from [UInt8]")
                            }
                            accumulator = []
                        }
                    }
                }
            }
            continuation.onTermination = { @Sendable _ in
                bytesTask.cancel()
            }
        }
    }
    
    
}

enum StreamError: Error {
    case couldNotMakeString(String)
}


