//
//  UITextFieldExtension.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 01.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setLeft(padding padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        leftView = view
        leftViewMode = .Always
    }
    
    func setRight(padding padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        rightView = view
        rightViewMode = .Always
    }
}
