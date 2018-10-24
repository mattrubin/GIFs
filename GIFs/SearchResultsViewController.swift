//
//  SearchResultsViewController.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import UIKit
import GiphyCoreSDK

/// The number of images to load per request.
private let pageSize = 100

private let reuseIdentifier = "Cell"

class SearchResultsViewController: UICollectionViewController {
    var searchInProgress: (query: String, operation: Operation)?
    var searchResults: SearchResults?

    init() {
        let layout = CollectionViewMasonryLayout()
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Search

    func search(for query: String) {
        if searchInProgress?.query == query {
            // If the requested query matches the query of the in-progress search results, no changes are necessary.
            print("Already searching for \"\(query)\".")
            return
        }
        discardSearchInProgress()

        if searchResults?.query == query {
            // If the requested query matches the query of the already-loaded results, no API call is necessary.
            print("Already showing results for \"\(query)\".")
            return
        }

        print("Searching for \"\(query)\"...")
        let searchOperation = GiphyCore.shared.search(query, limit: pageSize) { [weak self] (response, error) in
            if let error = error as NSError? {
                // TODO: Better error handling.
                print("error: \(error)")
            }

            if let response = response, let data = response.data, let pagination = response.pagination {
                // TODO: Check reponse metadata?
                // TODO: Implement reponse pagination?
                DispatchQueue.main.async {
                    let searchResults = SearchResults(query: query, media: data)
                    self?.update(with: searchResults)
                }
            } else {
                // TODO: Display a "no results" state in the UI.
                print("No Results Found")
            }
        }
        searchInProgress = (query: query, operation: searchOperation)
    }

    func clearResults() {
        discardSearchInProgress()

        if searchResults != nil {
            print("Clearing search results...")
            self.searchResults = nil
            self.collectionView.reloadData() // TODO: Use a more elegant update method.
        }
    }

    private func discardSearchInProgress() {
        if let operationInProgress = searchInProgress?.operation {
            if !operationInProgress.isFinished {
                print("Cancelling previous search...")
                operationInProgress.cancel()
            }
            searchInProgress = nil
        }
    }

    private func update(with searchResults: SearchResults) {
        print("Found \(searchResults.media.count) search results.")
        self.searchResults = searchResults
        self.collectionView.reloadData() // TODO: Use a more elegant update method.
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        collectionView.register(CollectionViewGIFCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white
        collectionView.keyboardDismissMode = .onDrag
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (searchResults == nil) ? 0 : 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults?.media.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        guard let media = searchResults?.media[indexPath.item] else {
            // Cannot configure a cell for an item that doesn't exist.
            return cell
        }

        if let gifCell = cell as? CollectionViewGIFCell {
            if let previewImage = media.images?.fixedWidth,
                let urlString = previewImage.gifUrl,
                let url = URL(string: urlString) {
                gifCell.setImageURL(url)
            }
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension SearchResultsViewController: CollectionViewMasonryLayoutDataSource {
    func originalSizeOfItem(at indexPath: IndexPath) -> CGSize {
        guard let media = searchResults?.media[indexPath.item],
            let originalImage = media.images?.original else {
                return .zero
        }

        return CGSize(width: originalImage.width, height: originalImage.height)
    }
}

struct SearchResults {
    let query: String
    let media: [GPHMedia]
}
