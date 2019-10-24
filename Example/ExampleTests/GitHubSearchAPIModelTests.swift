//
//  GitHubSearchAPIModelTests.swift
//  ExampleTests
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Necom
import XCTest
@testable import Example

class GitHubSearchAPIModelTests: XCTestCase {

    private var model: GitHubSearchAPIModel!
    private var session: MockURLSession!
    private var delegate: MockGitHubSearchAPIModelDelegate!

    override func setUp() {
        self.session = MockURLSession()
        self.model = GitHubSearchAPIModel(extra: .init(dataTask: session.dataTask))
        self.delegate = MockGitHubSearchAPIModelDelegate()
        model.connect(delegate)
    }

    func test_request() throws {
        let query = "Necom"
        model.action.searchRepository(query)
        let request = try XCTUnwrap(session.request)

        XCTAssertEqual(request.url?.query, "q=" + query)
    }

    func test_response_is_success() {
        let expected = [GitHub.Repository(name: "test-name",
                                          fullName: "test-fullName",
                                          htmlUrl: URL(string: "https://github.com")!)]
        session.mockResponse = .success(expected)
        model.action.searchRepository("")

        XCTAssertEqual(delegate._searchResponse?.items, expected)
    }

    func test_response_is_failure() {
        let expected = MockError()
        session.mockResponse = .failure(expected)
        model.action.searchRepository("")

        XCTAssertTrue(delegate._searchError is MockError)
    }
}

extension GitHubSearchAPIModelTests {

    private final class MockURLSession {

        private(set) var request: URLRequest?

        var mockResponse: Result<[GitHub.Repository], Error>?

        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask {
            self.request = request
            switch mockResponse {
            case let .success(repositories):
                let response = GitHub.ItemsResponse(items: repositories)
                do {
                    let data = try JSONEncoder().encode(response)
                    completionHandler(data, nil, nil)
                } catch {
                    completionHandler(nil, nil, error)
                }
            case let .failure(error):
                completionHandler(nil, nil, error)
            case nil:
                break
            }
            return MockSessionTask()
        }
    }

    private struct MockSessionTask: SessionTask {
        func resume() {}
        func cancel() {}
    }

    private struct MockError: Error {}

    private final class MockGitHubSearchAPIModelDelegate: GitHubSearchAPIModelDelegate {

        private(set) var _searchResponse: GitHub.ItemsResponse<GitHub.Repository>?
        private(set) var _searchError: Error?

        var searchResponse: Binder<GitHub.ItemsResponse<GitHub.Repository>> {
            Binder(self, \._searchResponse)
        }

        var searchError: Binder<Error> {
            Binder(self, \._searchError)
        }
    }
}
