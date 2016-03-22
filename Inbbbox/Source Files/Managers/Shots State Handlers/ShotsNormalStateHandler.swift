//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class ShotsNormalStateHandler: ShotsStateHandler {

    var collectionViewLayout: UICollectionViewLayout {
        return ShotsCollectionViewFlowLayout()
    }
    var tabBarInteractionEnabled: Bool {
        return true
    }
    var collectionViewInteractionEnabled: Bool {
        return true
    }

    func numberOfItems(shotsCollectionViewController: ShotsCollectionViewController, collectionView: UICollectionView, section: Int) -> Int {
        return 0
    }

    func configuredCell(shotsCollectionViewController: ShotsCollectionViewController, collectionView: UICollectionView, indexPath: NSIndexPath) -> ShotCollectionViewCell {
        return ShotCollectionViewCell()
    }

    func didSelectItem(shotsCollectionViewController: ShotsCollectionViewController, collectionView: UICollectionView, indexPath: NSIndexPath) {
    }

    func willDisplayCell(shotsCollectionViewController: ShotsCollectionViewController, collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: NSIndexPath) {
    }
}
