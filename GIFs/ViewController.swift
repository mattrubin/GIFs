//
//  ViewController.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var searchResultsController = SearchResultsViewController()
    lazy var searchController = UISearchController(searchResultsController: searchResultsController)
    lazy var giphy = GiphySearchController(delegate: searchResultsController)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "GIFs"

        view.backgroundColor = .black
        searchController.searchBar.tintColor = .white
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.placeholder = "Search Giphy"

        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

        // "The topViewController of the navigation controller containing the presented search controller must have
        // definesPresentationContext set to YES."
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchController.searchBar.becomeFirstResponder()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        // When search is cancelled and the search results view controller is dismissed, the status bar style reverts to the style defined by this view controller, instead of reverting the status bar style defined by the navigation controller. Forcing the light content status bar style works around the bug.
        return .lightContent
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            giphy.search(for: searchText)
        } else {
            giphy.clearSearch()
        }
    }
}
