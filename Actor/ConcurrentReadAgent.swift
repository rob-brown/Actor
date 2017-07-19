//
//  ConcurrentReadAgent.swift
//  Actor
//
//  Created by Robert Brown on 7/19/17.
//  Copyright © 2017 Robert Brown. All rights reserved.
//

import Foundation

public final class ConcurrentReadAgent<State> {

    private let queue: DispatchQueue
    private var state: State

    public convenience init(state: State, label: String = "pro.tricksofthetrade.ConcurrentReadAgent") {
        let queue = DispatchQueue(label: label, qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        self.init(state: state, queue: queue)
    }

    private init(state: State, queue: DispatchQueue) {
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
            barrierAsync { state in
                self.state = closure(state)
            }
        case .sync:
            barrierSync { state in
                self.state = closure(state)
            }
        }
    }

    public func fetchAndUpdate<Result>(closure: (State) -> (Result, State)) -> Result {
        var result: Result!
        barrierSync { state in
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

    private func barrierSync(closure: ((State) -> Void)) {
        queue.sync(flags: .barrier) {
            closure(state)
        }
    }

    private func barrierAsync(closure: @escaping ((State) -> Void)) {
        queue.async(group: nil, qos: .default, flags: .barrier) {
            closure(self.state)
        }
    }

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
