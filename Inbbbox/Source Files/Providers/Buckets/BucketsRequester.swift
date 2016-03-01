//
//  BucketsRequester.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/23/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class BucketsRequester {
    let apiBucketsRequester = APIBucketsRequester()
    let managedBucketsRequester = ManagedBucketsRequester()
    
    func addShot(shot: ShotType, toBucket bucket: BucketType) -> Promise<Void> {
        if UserStorage.userIsSignedIn {
            return apiBucketsRequester.addShot(shot, toBucket: bucket)
        }
        return managedBucketsRequester.addShot(shot, toBucket: bucket)
    }
    
    func removeShot(shot: ShotType, fromBucket bucket: BucketType) -> Promise<Void> {
        if UserStorage.userIsSignedIn {
            return apiBucketsRequester.removeShot(shot, fromBucket: bucket)
        }
        return managedBucketsRequester.removeShot(shot, fromBucket: bucket)
    }
}