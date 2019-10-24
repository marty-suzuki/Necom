//
//  SeedModel.swift
//  Necom
//
//  Created by marty-suzuki on 2019/10/22.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

public typealias SeedModel<Model: SeedModelType> = PrimitiveModel<Model> & SeedModelType

open class PrimitiveModel<Model: SeedModelType> {

    private let state: Model.State
    private let extra: Model.Extra
    private var delegate: Model.DelegateProxy?

    public private(set) lazy var action: ActionProxy<Model.Action> = { fatalError("action hasn't been initialized in \(type(of: self)). Should call `func connect(_:)`") }()

    public init(state: Model.State, extra: Model.Extra) {
        self.state = state
        self.extra = extra
    }

    public func connect(_ delegate: Model.DelegateProxy.Delegate) {
        let delegate =  Model.DelegateProxy(delegate: delegate)
        self.delegate = delegate
        self.action = ActionProxy(Model.make(state: StateProxy(state),
                                             extra: extra,
                                             delegate: delegate))
    }
}
