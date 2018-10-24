//
//  SearchResultsViewController.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SearchResultsViewController: UICollectionViewController {
    var searchResults: SearchResults?

    lazy var errorMessageLabel = UILabel()

    init() {
        let layout = CollectionViewMasonryLayout()
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        collectionView.register(CollectionViewGIFCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white
        collectionView.keyboardDismissMode = .onDrag

        // Initially hide the error message label.
        errorMessageLabel.isHidden = true
        errorMessageLabel.textColor = .white
        errorMessageLabel.textAlignment = .center

        // Center the error message in the top half of the view, to avoid the keyboard.
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorMessageLabel)
        view.addConstraints([
            errorMessageLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            errorMessageLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            errorMessageLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            errorMessageLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
        ])
    }

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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let media = searchResults?.media[indexPath.item] else {
            // Cannot select a cell for an item that doesn't exist.
            return
        }
        let detailViewController = DetailViewController(media: media)
        present(detailViewController, animated: true)
    }
}

extension SearchResultsViewController: GiphySearchControllerDelegate {
    func update(with searchResults: SearchResults) {
        clearErrorMessage()

        print("Found \(searchResults.media.count) search results.")
        self.searchResults = searchResults
        self.collectionView.reloadData() // TODO: Use a more elegant update method.
    }

    func update(withErrorMessage errorMessage: String) {
        clearSearchResults()

        errorMessageLabel.isHidden = false
        errorMessageLabel.text = errorMessage
    }

    func clear() {
        clearSearchResults()
        clearErrorMessage()
    }

    private func clearSearchResults() {
        if searchResults != nil {
            print("Clearing search results...")
            self.searchResults = nil
            self.collectionView.reloadData() // TODO: Use a more elegant update method.
        }
    }

    private func clearErrorMessage() {
        errorMessageLabel.isHidden = true
        errorMessageLabel.text = nil
    }
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
