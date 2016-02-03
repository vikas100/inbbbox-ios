//
//  TwoLayoutsCollectionViewController.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 28.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class TwoLayoutsCollectionViewController: UICollectionViewController {

    // MARK: - Lifecycle
    
    var cellHeightToWidthRatio = CGFloat(1)
    private var oneColumnLayoutButton: UIBarButtonItem?
    private var twoColumnsLayoutButton: UIBarButtonItem?
    
    convenience init(cellHeightToWidthRatio: CGFloat) {
        let flowLayout = TwoColumnsCollectionViewFlowLayout()
        flowLayout.itemHeightToWidthRatio = cellHeightToWidthRatio
        self.init(collectionViewLayout: flowLayout)
        self.cellHeightToWidthRatio = cellHeightToWidthRatio
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView else {
            return
        }
        collectionView.backgroundColor = UIColor.whiteColor()
        setupBarButtons()
        updateBarButtons(collectionView.collectionViewLayout)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = true
    }
    
    // MARK: Configuration
    
    func setupBarButtons() {
        // NGRTodo: set images instead of title
        oneColumnLayoutButton = UIBarButtonItem(title: "1", style: .Plain, target: self, action: "didTapOneColumnLayoutButton:")
        twoColumnsLayoutButton = UIBarButtonItem(title: "2", style: .Plain, target: self, action: "didTapTwoColumnsLayoutButton:")
        navigationItem.rightBarButtonItems = [oneColumnLayoutButton!, twoColumnsLayoutButton!]
    }
    
    func updateBarButtons(layout: UICollectionViewLayout) {
        let isCurrentLayoutOneColumn = layout.isKindOfClass(OneColumnCollectionViewFlowLayout)
        oneColumnLayoutButton?.enabled = !isCurrentLayoutOneColumn
        twoColumnsLayoutButton?.enabled = isCurrentLayoutOneColumn
    }
    
    // MARK: Actions:
    
    func didTapOneColumnLayoutButton(_: UIBarButtonItem) {
        changeLayout()
    }
    
    func didTapTwoColumnsLayoutButton(_: UIBarButtonItem) {
        changeLayout()
    }
    
    // Mark: Changing layout 
    
    func changeLayout() {
        guard let collectionView = collectionView else {
            return
        }
        if collectionView.collectionViewLayout.isKindOfClass(OneColumnCollectionViewFlowLayout) {
            let flowLayout = TwoColumnsCollectionViewFlowLayout()
            flowLayout.itemHeightToWidthRatio = cellHeightToWidthRatio
            collectionView.setCollectionViewLayout(flowLayout, animated: false)
        } else {
            let flowLayout = OneColumnCollectionViewFlowLayout()
            flowLayout.itemHeightToWidthRatio = cellHeightToWidthRatio
            collectionView.setCollectionViewLayout(flowLayout, animated: false)
        }
        scrollToTop(collectionView)
        updateBarButtons(collectionView.collectionViewLayout)
    }
    
    func scrollToTop(collectionView: UICollectionView) {
        if (collectionView.numberOfItemsInSection(0) > 0) {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        }
    }
}
