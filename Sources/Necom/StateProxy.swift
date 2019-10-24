//
//  StateProxy.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/22.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public class StateProxy<State: StateType> {

    private let lock = NSRecursiveLock()
    private var state: State

    internal init(_ state: State) {
        self.state = state
    }

    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<State, Value>) -> Value {
        get {
            lock.lock(); defer { lock.unlock() }
            return state[keyPath: keyPath]
        }
        set {
            lock.lock(); defer { lock.unlock() }
            state[keyPath: keyPath] = newValue
        }
    }
}
