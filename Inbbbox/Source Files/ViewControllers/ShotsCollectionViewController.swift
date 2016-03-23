//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit

class ShotsCollectionViewController: UICollectionViewController {

    enum State {
        case Onboarding, InitialAnimations, Normal
    }

    var stateHandler: ShotsStateHandler
    let shotsProvider = ShotsProvider()
    var shots = [ShotType]()
    private var onceTokenForInitialShotsAnimation = dispatch_once_t(0)

    //MARK - Life cycle

    @available(*, unavailable, message="Use init() method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        stateHandler = ShotsStateHandlersProvider().shotsStateHandlerForState(.Onboarding)
        super.init(collectionViewLayout: stateHandler.collectionViewLayout)
        stateHandler.shotsCollectionViewController = self
        stateHandler.delegate = self
    }
}

//MARK - UIViewController
extension ShotsCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.pagingEnabled = true
        collectionView?.backgroundView = ShotsCollectionBackgroundView()
        collectionView?.registerClass(ShotCollectionViewCell.self, type: .Cell)
        collectionView?.userInteractionEnabled = stateHandler.collectionViewInteractionEnabled
        collectionView?.scrollEnabled = stateHandler.colletionViewScrollEnabled
        tabBarController?.tabBar.userInteractionEnabled = stateHandler.tabBarInteractionEnabled
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        AnalyticsManager.trackScreen(.ShotsView)

        dispatch_once(&onceTokenForInitialShotsAnimation) {
            firstly {
                self.shotsProvider.provideShots()
                }.then { shots -> Void in
                    if let shots = shots {
                        self.shots = shots
                        self.stateHandler.presentData()
                    }
                }.error { error in
                    // NGRTemp: Need mockups for error message view
                    print(error)
            }
        }
    }
}

//MARK - UICollectionViewDataSource
extension ShotsCollectionViewController {

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stateHandler.collectionView(collectionView, numberOfItemsInSection: section)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return stateHandler.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
}

//MARK - UICollectionViewDelegate
extension ShotsCollectionViewController {

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        stateHandler.collectionView?(collectionView, didSelectItemAtIndexPath: indexPath)
    }

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        stateHandler.collectionView?(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
    }
}

//MARK - UIScrollViewDelegate
extension ShotsCollectionViewController {
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translationInView(scrollView.superview).y < 0 {
            AnalyticsManager.trackUserActionEvent(.SwipeDown)
        }
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let collectionView = collectionView else {
            return
        }
        let blur = min(scrollView.contentOffset.y % CGRectGetHeight(scrollView.bounds), CGRectGetHeight(scrollView.bounds) - scrollView.contentOffset.y % CGRectGetHeight(scrollView.bounds)) / (CGRectGetHeight(scrollView.bounds) / 2)

        for cell in collectionView.visibleCells() {
            if let shotCell = cell as? ShotCollectionViewCell {
                shotCell.shotImageView.applyBlur(blur)
            }
        }
    }
}

extension ShotsCollectionViewController: ShotsStateHandlerDelegate {
    func shotsStateHandlerDidInvalidate(shotsStateHandler: ShotsStateHandler) {
        if let nextState = shotsStateHandler.nextState {
            stateHandler = ShotsStateHandlersProvider().shotsStateHandlerForState(nextState)
            stateHandler.shotsCollectionViewController = self
            stateHandler.delegate = self
            collectionView?.userInteractionEnabled = stateHandler.collectionViewInteractionEnabled
            tabBarController?.tabBar.userInteractionEnabled = stateHandler.tabBarInteractionEnabled
            collectionView?.scrollEnabled = stateHandler.colletionViewScrollEnabled
            collectionView?.setCollectionViewLayout(stateHandler.collectionViewLayout, animated: false)
            collectionView?.reloadData()
        }
    }
}

extension ShotsCollectionViewController: ShotCollectionViewCellDelegate {

    func shotCollectionViewCellDidStartSwiping(_: ShotCollectionViewCell) {
        collectionView?.scrollEnabled = false && stateHandler.colletionViewScrollEnabled
    }

    func shotCollectionViewCellDidEndSwiping(_: ShotCollectionViewCell) {
        collectionView?.scrollEnabled = true && stateHandler.colletionViewScrollEnabled
    }
}

