//
//  CollectionViewMasonryLayout.swift
//  GIFs
//
//  Created by Matt Rubin on 10/23/18.
//  Copyright © 2018 Matt Rubin. All rights reserved.
//

import UIKit

/// A protocol representing a UICollectionViewDataSource which can also provide info required for masonry-style layout.
protocol CollectionViewMasonryLayoutDataSource: UICollectionViewDataSource {
    /// Returns a CGSize value representing the original size of the item to be displayed at the given index path.
    /// The original aspect ratio will be preserved when presenting the item in the masonry layout.
    func originalSizeOfItem(at indexPath: IndexPath) -> CGSize
}

/// A UICollectionViewLayout which presents items in mutiple columns, preserving the original aspect ratio of each item
/// and filling the columns in a "masonry" style.
class CollectionViewMasonryLayout: UICollectionViewLayout {
    /// The current computed layout.
    private var computedLayout: ComputedLayout?

    // MARK: - UICollectionViewLayout

    override func prepare() {
        super.prepare()

        // Discard the previous computed layout.
        computedLayout = nil

        // If this layout object is not in use by any collection view, a layout cannot be generated.
        guard let collectionView = collectionView else {
            return
        }
        // If the collection view's data source doesn't conform to CollectionViewMasonryLayoutDataSource, item sizes
        // aren't available to generate a layout.
        guard let dataSource = collectionView.dataSource as? CollectionViewMasonryLayoutDataSource else {
            return
        }

        // Construct a nested array representing the sections and the items in each section, containing a CGSize value
        // for each item.
        // If a UICollectionViewDataSource doesn't implement numberOfSections(in:), the number is assumed to be 1.
        let numberOfSections = dataSource.numberOfSections?(in: collectionView) ?? 1
        let itemSizes: [[CGSize]] = (0..<numberOfSections).map({ sectionIndex in
            let numberOfItems = dataSource.collectionView(collectionView, numberOfItemsInSection: sectionIndex)
            return (0..<numberOfItems).map({ itemIndex in
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                return dataSource.originalSizeOfItem(at: indexPath)
            })
        })

        // Compute the new layout.
        computedLayout = ComputedLayout(bounds: collectionView.bounds,
                                        margins: collectionView.layoutMargins,
                                        spacing: 8,
                                        itemSizes: itemSizes)
    }

    override var collectionViewContentSize: CGSize {
        // Return the computed content size, or .zero if no layout has been computed.
        return computedLayout?.contentSize ?? .zero
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Return the computed layout attributes, filtered for only those items whose frames intersect the given rect.
        return computedLayout?.layoutAttributes.values.filter({
            $0.frame.intersects(rect)
        })

    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return computedLayout?.layoutAttributes[indexPath]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let computedLayout = computedLayout else {
            return true
        }
        // If the current layout data is not valid for the new bounds, we should invalidate the layout.
        return !computedLayout.isValid(forBounds: newBounds)
    }
}

private extension CollectionViewMasonryLayout {
    /// An internal struct which encapsulates all of the computed layout data for the masonry layout.
    struct ComputedLayout {
        /// The bounds size for which the layout was generated, used to determine when the layout becomes invalid.
        let boundsSize: CGSize
        /// The content size which contains all the laid-out items.
        let contentSize: CGSize
        /// Layout attributes for all items, keyed by index path.
        let layoutAttributes: [IndexPath: UICollectionViewLayoutAttributes]

        // A magic number equivalent to 2 columns on the smallest supported screen width.
        private let minimumColumnWidth: CGFloat = 148

        /// Given the collection view's current bounds and layout margins, a spacing distance between items, and the
        /// original sizes of each item, computes a masonry-style layout for the items.
        init(bounds: CGRect, margins: UIEdgeInsets, spacing: CGFloat, itemSizes: [[CGSize]]) {
            boundsSize = bounds.size

            // Calculate an appropriate number of columns for the collection view's bounds and margins.
            let horizontalMargins = margins.left + margins.right
            let rawColumnCount = (boundsSize.width - horizontalMargins + spacing) / (minimumColumnWidth + spacing)
            // Ensure there is at least one column, even if its width is below our desired minimum.
            let columnCount = rawColumnCount > 1 ? Int(rawColumnCount.rounded(.down)) : 1
            let columnWidth = ((boundsSize.width - horizontalMargins + spacing) / CGFloat(columnCount)) - spacing

            /// An array containing the current maximum vertical offset of each column.
            var verticalOffsets = Array(repeating: spacing, count: columnCount)

            // Finds the column that is currently the shortest.
            func shortestColumn() -> (index: Int, verticalOffset: CGFloat) {
                let enumeratedColumns = verticalOffsets.enumerated().map({ ((index: $0, verticalOffset: $1)) })
                return enumeratedColumns.reduce(enumeratedColumns[0]) { (shortestColumn, nextColumn) in
                    if nextColumn.verticalOffset < shortestColumn.verticalOffset {
                        return nextColumn
                    } else {
                        return shortestColumn
                    }
                }
            }

            var layoutAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]

            // Loop through all items, in order by index path, and add them to the columns.
            for (sectionIndex, section) in itemSizes.enumerated() {
                for (itemIndex, itemSize) in section.enumerated() {
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)

                    // Calculate an appropriate cell size to fit the item in a column:
                    // Avoid divide-by-zero issues if the item has zero width.
                    let safeItemWidth = max(1, itemSize.width)
                    let scaleRatio = columnWidth / safeItemWidth
                    let rawCellHeight = itemSize.height * scaleRatio
                    // In most cases, the item can be scaled to fit in a column without any resizing, but here we limit
                    // the cell height to a minimum of the spacing size and a maximum of the bounds height. In case of
                    // an item with an extreme aspect ratio, this helps to avoid cells which are unusably short or
                    // disruptively tall.
                    let safeCellHeight = min(max(spacing, rawCellHeight), boundsSize.height)
                    let cellSize = CGSize(width: columnWidth, height: safeCellHeight)

                    // Find the current shortest column, and calculate a frame to add the item to that column.
                    let column = shortestColumn()
                    let horizontalOffset = margins.left + (CGFloat(column.index) * (columnWidth + spacing))
                    let cellFrame = CGRect(
                        origin: CGPoint(x: horizontalOffset, y: column.verticalOffset),
                        size: cellSize
                    )

                    // Create and store a layout attributes object for this index path.
                    let cellLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    cellLayoutAttributes.frame = cellFrame
                    layoutAttributes[indexPath] = cellLayoutAttributes

                    // Record the new vertical offset of the column.
                    verticalOffsets[column.index] = cellFrame.maxY + spacing
                }
            }

            let fullLayoutHeight = verticalOffsets.max() ?? 0
            contentSize = CGSize(width: boundsSize.width, height: fullLayoutHeight)
            self.layoutAttributes = layoutAttributes
        }

        func isValid(forBounds newBounds: CGRect) -> Bool {
            // If the new bounds have the same width, this layout is still valid.
            return boundsSize.width == newBounds.width
        }
    }
}
