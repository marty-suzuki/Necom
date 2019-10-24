//
//  ViewController.swift
//  Example
//
//  Created by marty-suzuki on 2019/10/25.
//  Copyright © 2019 jp.marty-suzuki. All rights reserved.
//

import Necom
import UIKit

protocol GitHubSearchView: AnyObject {
    var repositories: Binder<[GitHub.Repository]> { get }
    var errorMessage: Binder<String> { get }
}

final class ViewController: UIViewController {

    let searchBar = UISearchBar(frame: .zero)
    let tableView = UITableView(frame: .zero)

    private let presenter: GitHubSearchPresenterType = GitHubSearchPresenter()
    private var _repositories: [GitHub.Repository] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.dataSource = self

            view.addSubview(tableView)
            NSLayoutConstraint.activate([.top, .bottom, .right, .left].map {
                NSLayoutConstraint(item: view!,
                                   attribute: $0,
                                   relatedBy: .equal,
                                   toItem: tableView,
                                   attribute: $0,
                                   multiplier: 1,
                                   constant: 0)
            })

            navigationItem.titleView = searchBar
            searchBar.delegate = self
        }

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

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SubtitleTableViewCell
        let repository = _repositories[indexPath.row]
        cell.textLabel?.text = repository.fullName
        cell.detailTextLabel?.text = repository.htmlUrl.absoluteString
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.action.searchText(searchBar.text)
    }
}

final class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
