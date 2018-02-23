//
//  AppDelegate.swift
//  Journal
//
//  Created by Edward Huang on 1/7/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Theme stuff
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = .black
        
        
        let barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.7)
        UINavigationBar.appearance().barTintColor = barTintColor
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .topAttached, barMetrics: .default)
        UINavigationBar.appearance().backgroundColor = barTintColor
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UIToolbar.appearance().barTintColor = barTintColor
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        UIToolbar.appearance().backgroundColor = barTintColor
        
        let normalTitleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let disabledTitleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: normalTitleFont], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: disabledTitleFont], for: .disabled)
        UIBarButtonItem.appearance().tintColor = #colorLiteral(red: 0.3819544551, green: 0.3819544551, blue: 0.3819544551, alpha: 1)
        
        // Cache stuff
        EntryHistorian.contextWatcher = EntryHistorian()
        
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        if UserDefaults.standard.value(forKey: JournalLibrarian.userDefaultCurrentJournalKeyName) == nil {
            UserDefaults.standard.set(0, forKey: JournalLibrarian.userDefaultCurrentJournalKeyName)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        PersistentService.saveContext()
    }
}

