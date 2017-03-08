//
//  ManagedBlockedUsersRequester.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import PromiseKit
import CoreData

enum ManagedBlockedUserRequesterError: Error {
    case alreadyBlocked
    case doesNotExist
}

class ManagedBlockedUsersRequester {

    let managedObjectContext: NSManagedObjectContext
    let managedObjectsProvider: ManagedObjectsProvider

    init(managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext) {
        self.managedObjectContext = managedObjectContext
        managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: managedObjectContext)
    }

    func block(user: UserType) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            if let _ = managedObjectsProvider.managedBlockedUser(user) {
                reject(ManagedBlockedUserRequesterError.alreadyBlocked)
            }

            let managedUserEntity = NSEntityDescription.entity(forEntityName: ManagedBlockedUser.entityName, in: managedObjectContext)!
            let managedBlockedUser = ManagedBlockedUser(entity: managedUserEntity, insertInto: managedObjectContext)
            managedBlockedUser.mngd_identifier = user.identifier
            managedBlockedUser.mngd_name = user.name
            managedBlockedUser.mngd_username = user.username
            managedBlockedUser.mngd_avatarURL = user.avatarURL?.absoluteString

            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }

    func unblock(user: UserType) -> Promise<Void> {
        if let managedBlockedUser = managedObjectsProvider.managedBlockedUser(user) {
            managedObjectContext.delete(managedBlockedUser)
        }

        return Promise<Void> { fulfill, reject in
            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }
}