//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Dobby

@testable import Inbbbox

class ShotsAnimatorDelegateMock: ShotsAnimatorDelegate {

    let collectionViewForShotsAnimatorStub = Stub<(ShotsAnimator), UICollectionView?>()
    let itemsForShotsAnimatorStub = Stub<ShotsAnimator, [Shot]>()

    func collectionViewForShotsAnimator(animator: ShotsAnimator) -> UICollectionView? {
        return try! collectionViewForShotsAnimatorStub.invoke(animator)
    }

    func itemsForShotsAnimator(animator: ShotsAnimator) -> [Shot] {
        return try! itemsForShotsAnimatorStub.invoke(animator)
    }
}
