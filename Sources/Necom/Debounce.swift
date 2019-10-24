//
//  Debounce.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/24.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation

public protocol DebounceType {
    func execute(_ handler: @escaping () -> Void)
}

public final class Debounce: DebounceType {

    private var lastFireTime: DispatchTime = .now()
    private let queue: DispatchQueue = .global()
    private let delay: DispatchTimeInterval

    public init(delay: DispatchTimeInterval) {
        self.delay = delay
    }

    public func execute(_ handler: @escaping () -> Void) {
        let deadline: DispatchTime = .now() + delay
        lastFireTime = .now()
        queue.asyncAfter(deadline: deadline) { [delay, weak self] in
            guard let me = self else {
                return
            }
            let now: DispatchTime = .now()
            let when: DispatchTime = me.lastFireTime + delay
            if now < when { return }
            me.lastFireTime = .now()
            handler()
        }
    }
}
