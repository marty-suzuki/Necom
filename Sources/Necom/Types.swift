//
//  Types.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

public protocol SeedModelType {
    associatedtype Action: ActionType
    associatedtype State: StateType
    associatedtype Extra: ExtraType
    associatedtype DelegateProxy: DelegateProxyType
    static func make(state: StateProxy<State>,
                     extra: Extra,
                     delegate: DelegateProxy) -> Action
}

public protocol ActionType {}
public protocol StateType {}
public protocol ExtraType {}
public protocol ViewType: AnyObject {}

public struct NoState: StateType {
    public init() {}
}

public struct NoExtra: ExtraType {
    public init() {}
}
