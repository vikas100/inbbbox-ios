//
//  LoginViewController.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit

class LoginViewController: UIViewController {

    private var shotsAnimator: AutoScrollableShotsAnimator!
    private weak var aView: LoginView?
    private var viewAnimator: LoginViewAnimator?
    private var onceTokenForScrollToMiddleInstantly = dispatch_once_t(0)

    override func loadView() {
        aView = loadViewWithClass(LoginView.self)
        viewAnimator = LoginViewAnimator(view: aView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let bindForAnimation = aView?.shotsView.collectionViews.map {
            (collectionView: $0, shots: ShotsStorage().shotsFromAssetCatalog.shuffle())
        } ?? []

        shotsAnimator = AutoScrollableShotsAnimator(bindForAnimation: bindForAnimation)
        aView?.loginButton.addTarget(self, action: "loginButtonDidTap:", forControlEvents: .TouchUpInside)
        aView?.loginAsGuestButton.addTarget(self, action: "loginAsGuestButtonDidTap:", forControlEvents: .TouchUpInside)
        aView?.loadingLabel.alpha = 0
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        dispatch_once(&onceTokenForScrollToMiddleInstantly) {
            self.shotsAnimator.scrollToMiddleInstantly()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        shotsAnimator.startScrollAnimationInfinitely()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    deinit {
        shotsAnimator.stopAnimation()
    }
}

//MARK: Actions
extension LoginViewController {
    
    func loginButtonDidTap(_: UIButton) {
        
        viewAnimator?.startLoginAnimation()
        
        let interactionHandler: (UIViewController -> Void) = { controller in
            self.presentViewController(controller, animated: true, completion: nil)
        }
        let authenticator = Authenticator(interactionHandler: interactionHandler)
        
        firstly {
            authenticator.loginWithService(.Dribbble)
        }.then { _ -> Void in
            self.viewAnimator?.stopAnimationWithType(.Continue) {
                self.presentNextViewController()
            }
        }.error { error in
            self.viewAnimator?.stopAnimationWithType(.Undo)
        }
    }
    
    func loginAsGuestButtonDidTap(_: UIButton) {
        presentNextViewController()
    }
}

private extension LoginViewController {
    
    //NGRTemp: temporary implementation
    func presentNextViewController() {
        let containerViewController = PresentationContainerViewController()
        containerViewController.presentationSteps = [TabBarAnimationPresentationStep(), InitialShotsPresentationStep(), ShotsPresentationStep()]
        self.presentViewController(containerViewController, animated: false, completion: nil)
    }
}
