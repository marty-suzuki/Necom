//
//  TestHelper.swift
//  ExampleTests
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation
@testable import Example

extension GitHub.Repository {
    static var mock: GitHub.Repository {
        return GitHub.Repository(name: "test-name",
                                 fullName: "test-fullName",
                                 htmlUrl: URL(string: "https://github.com")!)
    }
}

struct MockError: Error, LocalizedError {
    let errorDescription = "MockError"
}

func undefined<T>() -> T {
    fatalError()
}
