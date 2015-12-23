//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class InitialShotsCollectionViewLayout: UICollectionViewLayout {

    private var bottomCellOffset = CGFloat(20)

//    MARK: - UICollectionViewLayout

    override func collectionViewContentSize() -> CGSize {
        return collectionView!.bounds.size
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesForVisibleElements = [UICollectionViewLayoutAttributes]()
        for indexPath in indexPathsOfItemsInRect(rect) {
            layoutAttributesForVisibleElements.append(layoutAttributesForItemAtIndexPath(indexPath)!)
        }
        return layoutAttributesForVisibleElements
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        if let collectionView = collectionView {
            let margin = CGFloat(30)
            let indexMultiplier = CGFloat(indexPath.item)
            layoutAttributes.size = CGSize(width: CGRectGetWidth(collectionView.bounds) - margin * 2 * (indexMultiplier + 1), height: ShotCollectionViewCell.prefferedHeight)
            layoutAttributes.center = CGPoint(x: collectionView.center.x, y: collectionView.center.y + bottomCellOffset * indexMultiplier)
            layoutAttributes.zIndex = -indexPath.row
        }
        return layoutAttributes
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        var boundsChanged = true
        if let collectionView = collectionView {
            let oldBounds = collectionView.bounds
            boundsChanged = !CGSizeEqualToSize(oldBounds.size, newBounds.size)
        }
        return boundsChanged
    }

    override func initialLayoutAttributesForAppearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = layoutAttributesForItemAtIndexPath(indexPath)
        if let collectionView = collectionView, layoutAttributes = layoutAttributes {
            layoutAttributes.center = collectionView.center
        }
        return layoutAttributes
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = layoutAttributesForItemAtIndexPath(indexPath)
        if let collectionView = collectionView, layoutAttributes = layoutAttributes {
            layoutAttributes.center = CGPoint(x: CGRectGetMidX(collectionView.bounds), y: CGRectGetMaxY(collectionView.bounds) + CGRectGetMaxY(layoutAttributes.bounds))
        }
        return layoutAttributes
    }

//    MARK: - Helpers

    private func indexPathsOfItemsInRect(rect: CGRect) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        if let collectionView = collectionView {
            for itemIndex in 0 ..< collectionView.numberOfItemsInSection(0) {
                indexPaths.append(NSIndexPath(forItem: itemIndex, inSection: 0))
            }
        }
        return indexPaths
    }
}
