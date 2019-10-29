//
//  GitHubSearchPresenterTests.swift
//  ExampleTests
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Necom
import XCTest
@testable import Example

class GitHubSearchPresenterTests: XCTestCase {

    private var searchLogicModel: MockGitHubSearchLogicModel!
    private var testTarget: GitHubSearchPresenter!
    private var view: MockGitHubSearchView!
    private var delegateProxy: DelegateProxy<GitHubSearchLogicModelDelegate>!

    override func setUp() {
        self.searchLogicModel = MockGitHubSearchLogicModel()
        self.view = MockGitHubSearchView()
        self.testTarget = GitHubSearchPresenter(searchLogicModel: searchLogicModel)
        testTarget.connect(view)
        self.delegateProxy = searchLogicModel.delegate
    }

    func test_query() {
        let query = "search query"
        testTarget.action.searchText(query)
        XCTAssertEqual(searchLogicModel.query, query)
        XCTAssertEqual(searchLogicModel.calledCount, 1)
    }

    func test_repositories() {
        let expected = [GitHub.Repository.mock]
        delegateProxy.repositories(expected)
        XCTAssertEqual(view.reloadDataCalledCount, 1)
        XCTAssertEqual(testTarget.state.repositories, expected)
    }

    func test_errorMessage() {
        let error = MockError()
        delegateProxy.error(error)
        XCTAssertEqual(view.errorMessage, error.localizedDescription)
    }
}

extension GitHubSearchPresenterTests {

    private final class MockGitHubSearchLogicModel: GitHubSearchLogicModelType {
        private(set) lazy var action: ActionProxy<GitHubSearchLogicModel.Action> = undefined()
        private(set) var delegate: DelegateProxy<GitHubSearchLogicModelDelegate>?

        private(set) var query: String?
        private(set) var calledCount = 0

        init() {
            self.action = ActionProxy(.init(searchText: { [weak self] in
                self?.query = $0
                self?.calledCount += 1
            }))
        }

        func connect(_ delegate: GitHubSearchLogicModelDelegate) {
            self.delegate = DelegateProxy(delegate: delegate)
        }
    }

    private final class MockGitHubSearchView: GitHubSearchView {
        private(set) var reloadDataCalledCount = 0
        private(set) var errorMessage: String?

        var reloadData: Binder<Void> {
            Binder(self) { me, _ in
                me.reloadDataCalledCount += 1
            }
        }

        var showErrorMessage: Binder<String> {
            Binder(self, \.errorMessage)
        }
    }
}
