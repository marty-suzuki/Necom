//
//  StateProxy.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/22.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public final class StateProxy<State: StateType> {

    private let lock = NSRecursiveLock()
    private var state: State

    fileprivate init(_ state: State) {
        self.state = state
    }

    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<State, Value>) -> Value {
        get {
            return value(for: keyPath)
        }
        set {
            lock.lock(); defer { lock.unlock() }
            state[keyPath: keyPath] = newValue
        }
    }

    fileprivate func value<Value>(for keyPath: KeyPath<State, Value>) -> Value {
        lock.lock(); defer { lock.unlock() }
        return state[keyPath: keyPath]
    }
}

@dynamicMemberLookup
public final class StateReference<State: StateType> {

    internal let proxy: StateProxy<State>

    internal init(_ state: State) {
        self.proxy = StateProxy(state)
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        return proxy.value(for: keyPath)
    }
}
