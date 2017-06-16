//
// ActorRegistry.Swift
//
// Copyright (c) 2017 Robert Brown
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public enum ActorRegistryError: Error {
    case idInUse
    case noSuchID
    case typeMismatch
}

public final class ActorRegistry {
    private let registry = Agent<[ID:Any]>(state: [:], label: "pro.tricksofthetrade.ActorRegistry")

    public init() {}

    public func lookup<T, U>(id: ID) throws -> Actor<T, U> {
        guard let mailbox = registry.fetch(closure: { $0[id] }) else { throw ActorRegistryError.noSuchID }
        guard let result = mailbox as? Actor<T, U> else { throw ActorRegistryError.typeMismatch }

        return result
    }

    public func register<T, U>(id: ID, actor: Actor<T, U>) throws {
        let error: ActorRegistryError? = registry.fetchAndUpdate { state in
            if state[id] == nil {
                var newState = state
                newState[id] = actor
                return (nil, newState)
            }
            else {
                return (.idInUse, state)
            }
        }

        if let e = error {
            throw e
        }
    }

    public func unregister(id: ID) {
        registry.update { state in
            var newState = state
            newState.removeValue(forKey: id)
            return newState
        }
    }
}

extension ActorRegistry {

    public struct ID: RawRepresentable, Equatable, Hashable, Comparable {
        public let rawValue: String

        public var hashValue: Int {
            return rawValue.hashValue
        }

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: ActorRegistry.ID, rhs: ActorRegistry.ID) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        public static func <(lhs: ActorRegistry.ID, rhs: ActorRegistry.ID) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}
