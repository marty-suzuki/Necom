//
//  DelegateProxy.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/22.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

@dynamicMemberLookup
public protocol DelegateProxyType: AnyObject {
    associatedtype Delegate
    init(delegate: Delegate)
    subscript<U>(dynamicMember keyPath: KeyPath<Delegate, Binder<U>>) -> (U) -> Void { get }
}

open class DelegateProxy<Delegate>: DelegateProxyType {

    private let delegate: () -> Delegate?

    required public init(delegate: Delegate) {
        let delegate = delegate as AnyObject
        self.delegate = { [weak delegate] in delegate as? Delegate }
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<Delegate, Binder<U>>) -> (U) -> Void {
        let d = delegate
        return { d()?[keyPath: keyPath].bind($0) }
    }
}
