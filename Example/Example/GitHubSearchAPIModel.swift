//
//  GitHubSearchAPIModel.swift
//  Example
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Foundation
import Necom

protocol GitHubSearchAPIModelDelegate: AnyObject {
    var searchResponse: Binder<GitHub.ItemsResponse<GitHub.Repository>> { get }
    var searchError: Binder<Error> { get }
}

protocol GitHubSearchAPIModelType: AnyObject {
    var action: ActionProxy<GitHubSearchAPIModel.Action> { get }
    func connect(_ delegate: GitHubSearchAPIModelDelegate)
}

final class GitHubSearchAPIModel: SeedModel<GitHubSearchAPIModel>, GitHubSearchAPIModelType {

    init(session: URLSession = .shared) {
        super.init(state: .init(), extra: Extra(session: session))
    }
}

extension GitHubSearchAPIModel {

    struct Action: ActionType {
        let searchRepository: (String) -> Void
    }

    struct State: StateType {
        var task: URLSessionTask?
    }

    struct Extra: ExtraType {
        let session: URLSession
    }

    static func make(state: StateProxy<State>,
                     extra: Extra,
                     delegate: DelegateProxy<GitHubSearchAPIModelDelegate>) -> Action {

        return Action(searchRepository: { query in
            guard var components = URLComponents(string: "https://api.github.com/search/repositories") else {
                return
            }
            components.queryItems = [URLQueryItem(name: "q", value: query)]

            guard let url = components.url else {
                return
            }

            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            state.task?.cancel()
            let task = extra.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    delegate.searchError(error)
                    return
                }

                guard let data = data else {
                    return
                }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let value = try decoder.decode(GitHub.ItemsResponse<GitHub.Repository>.self, from: data)
                    delegate.searchResponse(value)
                } catch {
                    delegate.searchError(error)
                }
            }
            task.resume()
            state.task = task
        })
    }
}

