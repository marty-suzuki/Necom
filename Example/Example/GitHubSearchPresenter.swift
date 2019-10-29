//
//  GitHubSearchPresenter.swift
//  Example
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Necom

protocol GitHubSearchPresenterType: AnyObject {
    var action: ActionProxy<GitHubSearchPresenter.Action> { get }
    var state: StateReference<GitHubSearchPresenter.State> { get }
    func connect(_ delegate: GitHubSearchView)
}

final class GitHubSearchPresenter: SeedModel<GitHubSearchPresenter>, GitHubSearchPresenterType {

    init(searchLogicModel: GitHubSearchLogicModelType = GitHubSearchLogicModel()) {
        super.init(state: .init(), extra: Extra(searchLogicModel: searchLogicModel))
    }
}

extension GitHubSearchPresenter {

    struct Action: ActionType {
        let searchText: (String?) -> Void
    }

    struct Extra: ExtraType {
        let searchLogicModel: GitHubSearchLogicModelType
    }

    struct State: StateType {
        var repositories = [GitHub.Repository]()
    }

    static func make(state: StateProxy<State>,
                     extra: Extra,
                     delegate: GitHubSearchViewProxy) -> Action {
        extra.searchLogicModel.connect(delegate)

        delegate.didReceiveRepositories = { state.repositories = $0 }

        return Action(searchText: { query in
            extra.searchLogicModel.action.searchText(query)
        })
    }
}

final class GitHubSearchViewProxy: DelegateProxy<GitHubSearchView>, GitHubSearchLogicModelDelegate {

    var didReceiveRepositories: (([GitHub.Repository]) -> Void)?

    var repositories: Binder<[GitHub.Repository]> {
        Binder(self) { me, repositories in
            me.didReceiveRepositories?(repositories)
            me.reloadData(())
        }
    }

    var error: Binder<Error> {
        Binder(self) { me, error in
            me.showErrorMessage(error.localizedDescription)
        }
    }
}

