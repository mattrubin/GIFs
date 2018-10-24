//
//  SearchController.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import Foundation
import GiphyCoreSDK

/// The number of images to load per request.
private let pageSize = 100

/// A search query and the resulting media returned from the Giphy API.
struct SearchResults {
    let query: String
    let media: [GPHMedia]
}

/// An object to be informed when a search completes or is cleared.
protocol GiphySearchControllerDelegate: class {
    /// Called when a search completes with results, which the delegate should display.
    func update(with searchResults: SearchResults)

    /// Called when a search completes with an error, which the delegate should display.
    func update(withErrorMessage errorMessage: String)

    /// Called when the search is cleared. The delegate should discard any displayed search results or error messages.
    func clear()
}

/// An object which creates and manages search requests to the Giphy API.
class GiphySearchController {
    weak var delegate: GiphySearchControllerDelegate?

    init(delegate: GiphySearchControllerDelegate) {
        self.delegate = delegate
    }

    // MARK: Search

    /// If a search is in progress, this variable holds the query string and a cancellable Operation object.
    private var searchInProgress: (query: String, operation: Operation)?
    /// The results of the last completed search.
    private var latestSearchResults: SearchResults?

    /// Makes a Giphy API call for GIFs matching the given query string.
    /// If a search for the given query is already in progress, this method does nothing.
    /// If the last completed search was for the given query, this method cancels any other search in progress.
    func search(for query: String) {
        // If the requested query matches the query of the in-progress search results, no changes are necessary.
        if searchInProgress?.query == query {
            print("Already searching for \"\(query)\".")
            return
        }
        // If a search is in progress that does not match the new query, cancel and discard it.
        discardSearchInProgress()

        // If the requested query matches the query of the already-loaded results, no API call is necessary.
        if latestSearchResults?.query == query {
            print("Already showing results for \"\(query)\".")
            return
        }

        // Make a new API request, and retain the search query and Operation.
        print("Searching for \"\(query)\"...")
        let searchOperation = GiphyCore.shared.search(query, limit: pageSize) { [weak self] (response, error) in
            // Dispatch back to the main queue before making any changes.
            DispatchQueue.main.async {
                // Recover a strong reference to self, or abort.
                guard let self = self else {
                    return
                }

                // Before processing any search results, guard against race conditions and operation cancellation
                // mistakes by ensuring that this completion block is being called for the current search-in-progress.
                // This can be confimed by checking that the current search-in-progress has the expected query string,
                // and by checking that the search operation is in a finished state.
                guard let searchInProgress = self.searchInProgress,
                    searchInProgress.query == query,
                    searchInProgress.operation.isFinished else {
                        print("Completion block called does not match searchInProgress:")
                        print("     Completion block query: \(query)")
                        print("     searchInProgress query: \(String(describing: self.searchInProgress?.query))")
                        return
                }

                // Discard the completed search operation and handle the search results.
                print("Search operation completed.")
                self.searchInProgress = nil
                self.handleCompletedSearch(query: query, response: response, error: error)
            }
        }
        searchInProgress = (query: query, operation: searchOperation)
    }

    /// Cancels any searches in progress and clears all search results.
    func clearSearch() {
        discardSearchInProgress()
        latestSearchResults = nil
        self.delegate?.clear()
    }

    // MARK: Private

    /// If a search is in progress, cancels the search operation and discard it.
    private func discardSearchInProgress() {
        if let searchInProgress = searchInProgress {
            let operationInProgress = searchInProgress.operation
            if !operationInProgress.isFinished {
                print("Cancelling previous search for \"\(searchInProgress.query)\"...")
                operationInProgress.cancel()
            }
            self.searchInProgress = nil
        }
    }

    /// Processes the search results (or error) and updates the delegate.
    private func handleCompletedSearch(query: String, response: GPHListMediaResponse?, error: Error?) {
        if let error = error {
            // Unfortunately, when an error occurs, the GiphyCoreSDK returns only an Error object with strings that are
            // not tailored for display to the user, and it does not return a GPHMeta object from which we can extract
            // failure status codes. Without a useful specific error message, show a generic one.
            print("ERROR: \(error)")
            self.delegate?.update(withErrorMessage: "🤕 Something went wrong.")
        } else if let response = response, let data = response.data {
            let searchResults = SearchResults(query: query, media: data)
            self.latestSearchResults = searchResults
            self.delegate?.update(with: searchResults)
        } else {
            // If the API call didn't return an error, and also didn't return a response object with useable data, then
            // show a generic error message.
            self.delegate?.update(withErrorMessage: "🤔 Something went wrong.")
        }
    }
}
