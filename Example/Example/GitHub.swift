//
//  GitHub.swift
//  Example
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation

enum GitHub {

    struct ItemsResponse<T: Codable>: Codable {
        let items: [T]
    }

    struct Repository: Codable, Equatable {
        let name: String
        let fullName: String
        let htmlUrl: URL
    }
}
