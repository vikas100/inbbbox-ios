//
//  AppDelegate.swift
//  Inbbbox
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import CoreData
import Haneke

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var centerButtonTabBarController: CenterButtonTabBarController?
    var launchedShortcut: UIApplicationShortcutItem?

    enum Shortcut: String {
        case Likes = "co.netguru.inbbbox.likes"
        case Buckets = "co.netguru.inbbbox.buckets"
        case Shots = "co.netguru.inbbbox.shots"
        case Followees = "co.netguru.inbbbox.followees"
    }

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {

        AnalyticsManager.setupAnalytics()
        CrashManager.setup()
        centerButtonTabBarController = CenterButtonTabBarController()
        let loginViewController = LoginViewController(tabBarController: centerButtonTabBarController!)
        let rootViewController = UserStorage.isUserSignedIn ? centerButtonTabBarController! : loginViewController
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = rootViewController
        window!.makeKeyAndVisible()
        window!.backgroundColor = UIColor.backgroundGrayColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.pinkColor()
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().translucent = false

        configureInitialSettings()
        CacheManager.setupCache()

        var shouldPerformAdditionalDelegateHandling = true
        if let shortcut = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            launchedShortcut = shortcut
            shouldPerformAdditionalDelegateHandling = false
        }

        return shouldPerformAdditionalDelegateHandling
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        // NGRTodo: start loading images from Dribbble,
        // but first, check if notificationID == currentUserID
    }

    func application(application: UIApplication,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        let notificationName = NotificationKey.UserNotificationSettingsRegistered.rawValue
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        guard let shortcut = launchedShortcut else { return }

        handleShortcutItem(shortcut)
        launchedShortcut = nil
    }

    func application(application: UIApplication,
                     performActionForShortcutItem shortcutItem: UIApplicationShortcutItem,
                                                  completionHandler: (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem)
        completionHandler(handledShortcutItem)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL? = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                inDomains: .UserDomainMask)
        return urls.last
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("StoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory?.URLByAppendingPathComponent("StoreData.sqlite")

        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: url,
                options: [NSMigratePersistentStoresAutomaticallyOption: true,
                          NSInferMappingModelAutomaticallyOption: true])
        } catch {
            let userInfo = [
                    NSLocalizedDescriptionKey: "Failed to initialize the application's saved data",
                    NSLocalizedFailureReasonErrorKey: "There was an error creating " +
                            "or loading the application's saved data."
            ]

            let wrappedError = NSError(domain: "co.netguru.inbbbox.coredata", code: 1001, userInfo: userInfo)

            // NGRTemp: Handle wrappedError

            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
}

// MARK: Initial configuration

private extension AppDelegate {

    func configureInitialSettings() {
        if !Settings.StreamSource.IsSet {
            Settings.StreamSource.PopularToday = true
            Settings.StreamSource.IsSet = true
        }
    }
}

// MARK: 3D Touch Support

private extension AppDelegate {

    private func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {

        guard UserStorage.isUserSignedIn else { return false }

        var handled = false
        if let shortcut = Shortcut(rawValue: shortcutItem.type) {
            typealias index = CenterButtonTabBarController.CenterButtonViewControllers
            switch shortcut {
            case .Likes:
                centerButtonTabBarController?.selectedIndex = index.Likes.rawValue
            case .Buckets:
                centerButtonTabBarController?.selectedIndex = index.Buckets.rawValue
            case .Shots:
                centerButtonTabBarController?.selectedIndex = index.Shots.rawValue
            case .Followees:
                centerButtonTabBarController?.selectedIndex = index.Followees.rawValue
            }
            handled = true
        }

        return handled
    }
}
