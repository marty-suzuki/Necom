//
//  GitHubSearchLogicModel.swift
//  Example
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Necom

protocol GitHubSearchLogicModelDelegate: AnyObject {
    var repositories: Binder<[GitHub.Repository]> { get }
    var error: Binder<Error> { get }
}

protocol GitHubSearchLogicModelType: AnyObject {
    var action: ActionProxy<GitHubSearchLogicModel.Action> { get }
    func connect(_ delegate: GitHubSearchLogicModelDelegate)
}

final class GitHubSearchLogicModel: SeedModel<GitHubSearchLogicModel>, GitHubSearchLogicModelType {

    init(extra: Extra = .init(searchAPIModel: GitHubSearchAPIModel(),
                              debounce: Debounce(delay: .milliseconds(300)))) {
        super.init(state: .init(), extra: extra)
    }
}

extension GitHubSearchLogicModel {

    struct Action: ActionType {
        let searchText: (String?) -> Void
    }

    struct Extra: ExtraType {
        let searchAPIModel: GitHubSearchAPIModelType
        let debounce: DebounceType
    }

    static func make(state: StateProxy<NoState>,
                     extra: Extra,
                     delegate: GitHubSearchLogicModelDelegateProxy) -> Action {
        extra.searchAPIModel.connect(delegate)

        return Action(searchText: { query in
            extra.debounce.execute {
                guard let query = query, !query.isEmpty else {
                    return
                }
                extra.searchAPIModel.action.searchRepository(query)
            }
        })
    }
}

final class GitHubSearchLogicModelDelegateProxy: DelegateProxy<GitHubSearchLogicModelDelegate>, GitHubSearchAPIModelDelegate {

    var searchResponse: Binder<GitHub.ItemsResponse<GitHub.Repository>> {
        Binder(self) { me, response in
            me.repositories(response.items)
        }
    }

    var searchError: Binder<Error> {
        Binder(self) { me, error in
            me.error(error)
        }
    }
}

