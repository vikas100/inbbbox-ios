//
//  LargeFolloweeCollectionViewCell.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 03.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class LargeFolloweeCollectionViewCell: BaseInfoShotsCollectionViewCell, Reusable, WidthDependentHeight, InfoShotsCellConfigurable, AvatarSettable {
    
    let shotImageView = UIImageView.newAutoLayoutView()
    var avatarView: AvatarView!
    let avatarSize = CGSize(width:16, height:16)
    private var didSetConstraints = false
    
    // MARK: - Lifecycle
    
    override func commonInit() {
        super.commonInit()
        setupAvatar()
        setupShotsView()
    }
    
    // MARK: - UIView
    
    override func updateConstraints() {
        if !didSetConstraints {
            setShotsViewConstraints()
            setInfoViewConstraints()
            didSetConstraints = true
        }
        super.updateConstraints()
    }
    
    // MARK - Avatar settable
    
    func setupAvatar() {
        avatarView = AvatarView(avatarFrame: CGRect(origin: CGPointZero, size: avatarSize), bordered: false)
        avatarView.imageView.backgroundColor = UIColor.backgroundGrayColor()
        avatarView.configureForAutoLayout()
        infoView.addSubview(avatarView)
    }
    
    // MARK: - Info Shots Cell Configurable
    
    func setupShotsView() {
        shotImageView.backgroundColor = UIColor.followeeShotGrayColor()
        shotsView.addSubview(shotImageView)
    }
    
    func setShotsViewConstraints() {
        shotImageView.autoPinEdgesToSuperviewEdges()
    }
    
    func setInfoViewConstraints() {
        avatarView.autoSetDimensionsToSize(avatarSize)
        avatarView.autoPinEdge(.Left, toEdge: .Left, ofView: infoView, withOffset: 2)
        avatarView.autoPinEdge(.Top, toEdge: .Top, ofView: infoView, withOffset: 10)
        
        nameLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: avatarView)
        nameLabel.autoPinEdge(.Left, toEdge: .Right, ofView: avatarView, withOffset: 3)
        nameLabel.autoPinEdge(.Right, toEdge: .Left, ofView: numberOfShotsLabel)
        
        numberOfShotsLabel.autoPinEdge(.Right, toEdge: .Right, ofView: infoView, withOffset: -2)
        numberOfShotsLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: nameLabel)
    }
    
    // MARK: - Reusable
    
    static var reuseIdentifier: String {
        return "LargeFolloweeCollectionViewCellIdentifier"
    }
    
    //MARK: - Width dependent height
    
    static var heightToWidthRatio: CGFloat {
        return CGFloat(0.83)
    }
}
