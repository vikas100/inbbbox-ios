//
// Created by Lukasz Pikor on 26.04.2016.
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

extension AppDelegate {

    func rollbackToLoginViewController() {
        let centerTabBarController = CenterButtonTabBarController()
        let rootViewController = LoginViewController(tabBarController: centerTabBarController)
        setCenterTabBarController(rootViewController.centerButtonTabBarController)
        UIApplication.sharedApplication().keyWindow?.setRootViewController(rootViewController, transition: nil)
    }

    private func setCenterTabBarController(tabBarController: CenterButtonTabBarController) {
        centerButtonTabBarController = tabBarController
    }
}
