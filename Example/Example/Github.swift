//
//  Github.swift
//  Example
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation

enum GitHub {

    struct ItemsResponse<T: Decodable>: Decodable {
        let items: [T]
    }

    struct Repository: Decodable, Equatable {
        let name: String
        let fullName: String
        let htmlUrl: URL
    }
}
