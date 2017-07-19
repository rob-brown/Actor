//
// Agent.Swift
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

public enum AgentConcurrencyType {
    case sync
    case async
}

public final class Agent<State> {

    private let queue: DispatchQueue
    private var state: State

    public convenience init(state: State, label: String = "pro.tricksofthetrade.Agent") {
        let queue = DispatchQueue(label: label, qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
        self.init(state: state, queue: queue)
    }

    public init(state: State, queue: DispatchQueue) {
        self.state = state
        self.queue = queue
    }

    public func fetch<Result>(closure: ((State) -> Result)) -> Result {
        var result: Result!
        sync { state in
            result = closure(state)
        }
        return result
    }

    public func update(_ type: AgentConcurrencyType = .async, closure: @escaping (State) -> State) {
        switch type {
        case .async:
            async { state in
                self.state = closure(state)
            }
        case .sync:
            sync { state in
                self.state = closure(state)
            }
        }
    }

    public func fetchAndUpdate<Result>(closure: (State) -> (Result, State)) -> Result {
        var result: Result!
        sync { state in
            let (returnValue, newState) = closure(state)
            self.state = newState
            result = returnValue
        }
        return result
    }

    public func cast(closure: @escaping ((State) -> Void)) {
        async(closure: closure)
    }

    // MARK: - Helpers

    private func sync(closure: ((State) -> Void)) {
        queue.sync {
            closure(state)
        }
    }

    private func async(closure: @escaping ((State) -> Void)) {
        queue.async {
            closure(self.state)
        }
    }
}
