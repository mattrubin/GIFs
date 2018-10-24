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
    var searchOperationInProgress: Operation?
    var searchResults: [GPHMedia]?

    init() {
        let layout = CollectionViewMasonryLayout()
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Search

    func search(for query: String) {
        print("Searching for \"\(query)\"...")
        discardSearchOperationInProgress()

        searchOperationInProgress = GiphyCore.shared.search(query, limit: pageSize) { [weak self] (response, error) in
            if let error = error as NSError? {
                // TODO: Better error handling.
                print("error: \(error)")
            }

            if let response = response, let data = response.data, let pagination = response.pagination {
                // TODO: Check reponse metadata?
                // TODO: Implement reponse pagination?
                DispatchQueue.main.async {
                    self?.update(with: data)
                }
            } else {
                // TODO: Display a "no results" state in the UI.
                print("No Results Found")
            }
        }
    }

    func clearResults() {
        print("Clearing search results...")
        discardSearchOperationInProgress()

        self.searchResults = nil
        self.collectionView.reloadData() // TODO: Use a more elegant update method.
    }

    private func discardSearchOperationInProgress() {
        if let opInProgress = searchOperationInProgress {
            if !opInProgress.isFinished {
                print("Cancelling previous search...")
                opInProgress.cancel()
            }
            searchOperationInProgress = nil
        }
    }

    private func update(with searchResults: [GPHMedia]) {
        print("Found \(searchResults.count) search results.")
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
        return searchResults?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        guard let media = searchResults?[indexPath.item] else {
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
        guard let media = searchResults?[indexPath.item],
            let originalImage = media.images?.original else {
                return .zero
        }

        return CGSize(width: originalImage.width, height: originalImage.height)
    }
}
