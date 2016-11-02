//
//  FlasMessage.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/2/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class FlashMessageView: UIView {
    
    private let defaultPadding:CGFloat = 15.0
    
    struct Style {
        let backgroundColor: UIColor
        let textColor: UIColor
        let titleFont: UIFont?
        let roundedCorners: UIRectCorner?
        let roundSize: CGSize?
        let padding: CGFloat
        
        init (backgroundColor: UIColor, textColor: UIColor, titleFont: UIFont? = nil, roundedCorners:UIRectCorner? = nil, roundSize:CGSize? = nil, padding: CGFloat = 15.0){
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.titleFont = titleFont
            self.roundedCorners = roundedCorners
            self.roundSize = roundSize
            self.padding = padding
        }
    }
    
    /// The displayed title of this message
    let title: String
    
    /// The view controller this message is displayed in
    let viewController: UIViewController
    
    /// The duration of the displayed message.
    var duration: FlashMessageDuration = .Automatic
    
    /// The position of the message (top or bottom or as overlay)
    var messagePosition: FlashMessageNotificationPosition
    
    /// Is the message currenlty fully displayed? Is set as soon as the message is really fully visible
    var messageIsFullyDisplayed = false
    
    
    /// Function to customize style globally, initialized to default style. Priority will be This  customOptions in init > styleForMessageType
    static var defaultStyle: Style = {
        return Style(
            backgroundColor: UIColor.blackColor(),
            textColor: UIColor.whiteColor(),
            titleFont: UIFont.systemFontOfSize(16)
        )
    }()
    
    var fadeOut: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let backgroundView = UIView()
    private var textSpaceLeft: CGFloat = 0
    private var textSpaceRight: CGFloat = 0
    private var callback: (()-> Void)?
    private let padding: CGFloat
    private let style: Style!
    
    // MARK: Lifecycle
    
    /// Inits the notification view. Do not call this from outside this library.
    ///
    /// - parameter title:  The title of the notification view
    /// - parameter duration:  The duration this notification should be displayed
    /// - parameter viewController:  The view controller this message should be displayed in
    /// - parameter callback:  The block that should be executed, when the user tapped on the message
    /// - parameter position:  The position of the message on the screen
    /// - parameter dismissingEnabled:  Should this message be dismissed when the user taps/swipes it?
    /// - parameter style:  Override default/global style
    init(viewController: UIViewController,
         title: String,
         duration: FlashMessageDuration?,
         position: FlashMessageNotificationPosition,
         style customStyle: Style?,
         dismissingEnabled: Bool,
         callback: (()-> Void)?) {
        
        self.style = customStyle ?? FlashMessageView.defaultStyle
        self.title = title
        self.duration = duration ?? .Automatic
        self.viewController = viewController
        self.messagePosition = position
        self.callback = callback
        self.padding = messagePosition == .NavBarOverlay ? style.padding + 10 : style.padding
        super.init(frame: CGRect.zero)
        
        setupBackground()
        setupTitle()
        setupPosition()
        setupGestureForDismiss(ifNeeded: dismissingEnabled)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let roundedCorners = style.roundedCorners,
            let roundSize = style.roundSize else {
                return
        }
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: roundedCorners, cornerRadii: roundSize)
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeightOfMessageView()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if duration == .Endless && superview != nil && window == nil {
            // view controller was dismissed, let's fade out
            fadeMeOut()
        }
    }
    
    // MARK: Setups
    
    private func setupBackground() {
        backgroundColor = UIColor.clearColor()
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundView.backgroundColor = style.backgroundColor
        addSubview(backgroundView)
    }
    
    private func setupTitle() {
        let fontColor: UIColor = style.textColor
        textSpaceLeft = padding
        
        titleLabel.text = title
        titleLabel.textColor = fontColor
        titleLabel.backgroundColor = UIColor.clearColor()
        
        titleLabel.font = style.titleFont ?? UIFont.boldSystemFontOfSize(14)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        addSubview(titleLabel)

    }
    
    private func setupPosition() {
        let screenWidth: CGFloat = viewController.view.bounds.size.width
        let actualHeight: CGFloat = updateHeightOfMessageView()
        
        var topPosition: CGFloat = -actualHeight
        if messagePosition == .Bottom {
            topPosition = viewController.view.bounds.size.height
        }
        frame = CGRectMake(0.0, topPosition, screenWidth, actualHeight)
        if messagePosition == .Top {
            autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin, .FlexibleBottomMargin]
        }
        else {
            autoresizingMask = ([.FlexibleWidth, .FlexibleTopMargin, .FlexibleBottomMargin])
        }
    }
    
    private func setupGestureForDismiss(ifNeeded dismissingEnabled: Bool) {
        if dismissingEnabled {
            let gestureRec: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FlashMessageView.fadeMeOut))
            gestureRec.direction = (messagePosition == .Top ? .Up : .Down)
            addGestureRecognizer(gestureRec)
            let tapRec: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FlashMessageView.fadeMeOut))
            addGestureRecognizer(tapRec)
        }
    }
    
    // MARK: Private methods
    
    private func updateHeightOfMessageView() -> CGFloat {
        
        let screenWidth: CGFloat = viewController.view.bounds.size.width
        titleLabel.frame = CGRectMake(textSpaceLeft, padding, screenWidth - padding - textSpaceLeft - textSpaceRight, 0.0)
        titleLabel.sizeToFit()
        var currentHeight = titleLabel.frame.origin.y + titleLabel.frame.size.height
        currentHeight += padding
        
        frame = CGRectMake(0.0, frame.origin.y, frame.size.width, currentHeight)
        
        var backgroundFrame: CGRect = CGRectMake(0, 0, screenWidth, currentHeight)
        // increase frame of background view because of the spring animation
        if messagePosition == .Top {
            var topOffset: CGFloat = 0.0
            let navigationController: UINavigationController? = viewController as? UINavigationController ?? viewController.navigationController
            
            if let nav = navigationController {
                let isNavBarIsHidden: Bool =  nav.navigationBarHidden || nav.navigationBar.hidden
                let isNavBarIsOpaque: Bool = !nav.navigationBar.translucent && nav.navigationBar.alpha == 1
                if isNavBarIsHidden || isNavBarIsOpaque {
                    topOffset = -30.0
                }
            }
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.0, 0.0, 0.0))
        }
        else if messagePosition == .Bottom {
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.0, 0.0, -30.0, 0.0))
        }
        backgroundView.frame = backgroundFrame
        return currentHeight
    }
    
    @objc
    private func fadeMeOut() {
        fadeOut?()
    }
}

// MARK: UIGestureRecognizerDelegate
extension FlashMessageView: UIGestureRecognizerDelegate {
    func handleTap(tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .Recognized {
            callback?()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return touch.view is UIControl
    }
}
