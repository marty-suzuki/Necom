//
//  Binder.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/22.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation

public enum BindingQueue {
    case current
    case main
    case global
}

public struct Binder<Value> {

    internal let bind: (Value) -> Void

    public init<Root: AnyObject>(_ root: Root, _ keyPath: ReferenceWritableKeyPath<Root, Value>, in queue: BindingQueue = .current) {
        self.bind = { [weak root] value in
            handle(in: queue) { root?[keyPath: keyPath] = value }
        }
    }

    public init<Root: AnyObject>(_ root: Root, _ keyPath: ReferenceWritableKeyPath<Root, Value?>, in queue: BindingQueue = .current) {
        self.bind = { [weak root] value in
            handle(in: queue) { root?[keyPath: keyPath] = value }
        }
    }

    public init<Root: AnyObject>(_ root: Root, queue: BindingQueue = .current, handler: @escaping (Root, Value) -> Void) {
        self.bind = { [weak root] value in
            handle(in: queue) { root.map { handler($0, value) } }
        }
    }
}

private func handle(in queue: BindingQueue, execute: @escaping () -> Void) {
    switch queue {
    case .current:
        execute()
    case .main:
        if Thread.isMainThread {
            execute()
        } else {
            DispatchQueue.main.async(execute: execute)
        }
    case .global:
        DispatchQueue.global().async(execute: execute)
    }
}
