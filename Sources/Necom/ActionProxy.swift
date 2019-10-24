//
//  ActionProxy.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/22.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public final class ActionProxy<Action: ActionType> {

    private let action: Action

    public init(_ action: Action) {
        self.action = action
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Action, () -> T>) -> () -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1>(dynamicMember keyPath: KeyPath<Action, (T1) -> T>) -> (T1) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2>(dynamicMember keyPath: KeyPath<Action, (T1, T2) -> T>) -> (T1, T2) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2, T3>(dynamicMember keyPath: KeyPath<Action, (T1, T2, T3) -> T>) -> (T1, T2, T3) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2, T3, T4>(dynamicMember keyPath: KeyPath<Action, (T1, T2, T3, T4) -> T>) -> (T1, T2, T3, T4) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2, T3, T4, T5>(dynamicMember keyPath: KeyPath<Action, (T1, T2, T3, T4, T5) -> T>) -> (T1, T2, T3, T4, T5) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2, T3, T4, T5, T6>(dynamicMember keyPath: KeyPath<Action, (T1, T2, T3, T4, T5, T6) -> T>) -> (T1, T2, T3, T4, T5, T6) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2, T3, T4, T5, T6, T7>(dynamicMember keyPath: KeyPath<Action, (T1, T2, T3, T4, T5, T6, T7) -> T>) -> (T1, T2, T3, T4, T5, T6, T7) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2, T3, T4, T5, T6, T7, T8>(dynamicMember keyPath: KeyPath<Action, (T1, T2, T3, T4, T5, T6, T7, T8) -> T>) -> (T1, T2, T3, T4, T5, T6, T7, T8) -> T {
        action[keyPath: keyPath]
    }

    public subscript<T, T1, T2, T3, T4, T5, T6, T7, T8, T9>(dynamicMember keyPath: KeyPath<Action, (T1, T2, T3, T4, T5, T6, T7, T8, T9) -> T>) -> (T1, T2, T3, T4, T5, T6, T7, T8, T9) -> T {
        action[keyPath: keyPath]
    }
}
