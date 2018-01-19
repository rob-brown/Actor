//
// PureStateMachine.swift
//
// Copyright (c) 2018 Robert Brown
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

// Based on Elm architecture and https://gist.github.com/andymatuschak/d5f0a8730ad601bcccae97e8398e25b2

public final class PureStateMachine<State, Event, Command> {
    public typealias EventHandler = (State, Event) -> (State, Command)

    public var currentState: State {
        return state.fetch { $0 }
    }

    private let state: Agent<State>
    private let handler: EventHandler

    public convenience init(initialState: State, label: String = "pro.tricksofthetrade.PureStateMachine", handler: @escaping EventHandler) {
        let state = Agent(state: initialState, label: label)
        self.init(state: state, handler: handler)
    }

    public convenience init(initialState: State, queue: DispatchQueue, handler: @escaping EventHandler) {
        let state = Agent(state: initialState, queue: queue)
        self.init(state: state, handler: handler)
    }

    private init(state: Agent<State>, handler: @escaping EventHandler) {
        self.state = state
        self.handler = handler
    }

    public func handleEvent(_ event: Event) -> Command {
        return state.fetchAndUpdate {
            let (newState, command) = self.handler($0, event)
            return (command, newState)
        }
    }
}
