//
// Created by Lukasz Pikor on 12.04.2016.
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol Numeric {}

extension Numeric {
    func currentLocaleDecimalStyle() -> String? {
        let formatter = NSNumberFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.numberStyle = .DecimalStyle
        return formatter.stringFromNumber(self as! NSNumber)
    }
}

extension UInt: Numeric {}
extension Int: Numeric {}
extension Double: Numeric {}
