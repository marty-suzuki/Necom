# Necom

🐈**Ne**w **c**oncept **o**f **M**VP with Swift.

## Concept

Necom is based on Delegate pattern.

## Usage

### Model

```swift
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
```

### View

```swift
protocol GitHubSearchView: AnyObject {
    var repositories: Binder<[GitHub.Repository]> { get }
    var errorMessage: Binder<String> { get }
}

final class ViewController: UIViewController {
    let searchBar = UISearchBar(frame: .zero)
    let tableView = UITableView(frame: .zero)

    private let presenter = GitHubSearchPresenter()
    private var _repositories: [GitHub.Repository] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        ...
        presenter.connect(self)
    }
}

extension ViewController: GitHubSearchView {
    var repositories: Binder<[GitHub.Repository]> {
        Binder(self, queue: .main) { me, repositories in
            me._repositories = repositories
            me.tableView.reloadData()
        }
    }

    var errorMessage: Binder<String> {
        Binder(self, queue: .main) { me, message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            me.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.action.searchText(searchBar.text)
    }
}
```

### Presenter

```swift
final class GitHubSearchPresenter: SeedModel<GitHubSearchPresenter> {
    init(searchLogicModel: GitHubSearchLogicModelType = GitHubSearchLogicModel()) {
        super.init(state: .init(), extra: Extra(searchLogicModel: searchLogicModel))
    }

    struct Action: ActionType {
        let searchText: (String?) -> Void
    }

    struct Extra: ExtraType {
        let searchLogicModel: GitHubSearchLogicModelType
    }

    static func make(state: StateProxy<NoState>,
                     extra: Extra,
                     delegate: GitHubSearchViewProxy) -> Action {
        extra.searchLogicModel.connect(delegate)

        return Action(searchText: { query in
            extra.searchLogicModel.action.searchText(query)
        })
    }
}

final class GitHubSearchViewProxy: DelegateProxy<GitHubSearchView>, GitHubSearchLogicModelDelegate {
    var repositories: Binder<[GitHub.Repository]> {
        Binder(self) { me, repositories in
            me.repositories(repositories)
        }
    }

    var error: Binder<Error> {
        Binder(self) { me, error in
            me.errorMessage(error.localizedDescription)
        }
    }
}
```

## Testing

```swift
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
        XCTAssertEqual(view._repositories, expected)
    }

    func test_errorMessage() {
        let error = MockError()
        delegateProxy.error(error)
        XCTAssertEqual(view._errorMessage, error.localizedDescription)
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
        private(set) var _repositories: [GitHub.Repository]?
        private(set) var _errorMessage: String?

        var repositories: Binder<[GitHub.Repository]> {
            Binder(self, \._repositories)
        }

        var errorMessage: Binder<String> {
            Binder(self, \._errorMessage)
        }
    }
}
```
