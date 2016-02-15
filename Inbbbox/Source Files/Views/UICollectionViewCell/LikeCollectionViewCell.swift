//
//  LikeCollectionViewCell.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 26.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class LikeCollectionViewCell: UICollectionViewCell, Reusable, WidthDependentHeight {
    
    let shotImageView = UIImageView.newAutoLayoutView()
    private var didSetConstraints = false

    // MARK - Life cycle
    
    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        contentView.addSubview(shotImageView)
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    // MARK - UIView
    
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            shotImageView.autoPinEdgesToSuperviewEdges()
            didSetConstraints = true
        }
    }
    
    // MARK: - Reusable
    static var reuseIdentifier: String {
        return "LikeCollectionViewCellIdentifier"
    }
    
    //MARK: - Width dependent height
    static var heightToWidthRatio: CGFloat {
        return CGFloat(0.75)
    }
}