//
//  NotificationManager.swift
//  Inbbbox
//
//  Created by Peter Bruz on 21/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class NotificationManager {
    
    private static let LocalNotificationUserIDKey = "notificationID"
    
    class func registerNotification(forUserID userID: String, time: NSDate) {
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
        
        unregisterNotification(forUserID: userID)
        
        createNotification(forUserID: userID, atTime: time)
    }
    
    class func unregisterNotification(forUserID userID: String) {
        
        if let registeredNotification = getRegisteredNotification(forUserID: userID) {
            destroyNotification(notificationID: registeredNotification)
        }
    }
}

// MARK: Private

private extension NotificationManager {
    
    class func createNotification(forUserID userID: String, atTime: NSDate) {
        
        let localNotification = UILocalNotification()
        localNotification.userInfo = [LocalNotificationUserIDKey: userID]
        localNotification.fireDate = atTime
        localNotification.alertBody = NSLocalizedString("Check Inbbbox!", comment: "") // NGRTemp: temp text
        localNotification.alertAction = NSLocalizedString("Show", comment: "") // NGRTemp: temp text
        localNotification.repeatInterval = .Day
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    class func destroyNotification(notificationID notificationToDelete: UILocalNotification) {
        UIApplication.sharedApplication().cancelLocalNotification(notificationToDelete)
    }
    
    class func getRegisteredNotification(forUserID userID: String) -> UILocalNotification? {
        
        guard let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications else {
            return nil
        }
        
        let notifications = scheduledLocalNotifications.filter {
            if let userinfo = $0.userInfo as? [String: String] {
                return userinfo[LocalNotificationUserIDKey] == userID
            }
            return false
        }
        
        return notifications.count > 0 ? notifications.first : nil
    }
}