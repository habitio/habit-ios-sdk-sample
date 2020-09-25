//
//  AppDelegate.swift
//  HabitAnalyticsSDKSample
//
//  Created by Ana Figueira on 31/07/2019.
//  Copyright © 2019 Habit Analytics. All rights reserved.
//

import UIKit
import HabitAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HabitAnalyticsDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        HabitAnalytics.shared.handleBGFetch { (result) in
            completionHandler(result)
            return
        }
    }
    
    func HabitAnalyticsStatusChange(statusCode: HabitStatusCode)
    {
        print("\(statusCode) : \(HabitStatusCodes.getDescription(code: statusCode))")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(1800))
        
        guard let loadedCapabilityBluetooth = StorageHelper.load(key: StorageHelper.key_CapabilityBluetooth) as! Bool? else { return true }
        
        guard let loadedCapabilityLocation = StorageHelper.load(key: StorageHelper.key_CapabilityLocation) as! Bool? else { return true }
        
        guard let loadedCapabilityMotion = StorageHelper.load(key: StorageHelper.key_CapabilityMotion) as! Bool? else { return true }
        
        guard let loadedUXCapability = StorageHelper.load(key: StorageHelper.key_CapabilityUXEvents) as! Bool? else { return true }
        
        let loadedExternalID = StorageHelper.load(key: StorageHelper.key_externalID) as? String?
                
        let config = Configuration()

        config.capabilities.bluetooth = loadedCapabilityBluetooth
        config.capabilities.location = loadedCapabilityLocation
        config.capabilities.motion = loadedCapabilityMotion
        config.capabilities.ux_events = loadedUXCapability
        
        config.uxEventsConfig.token = Configurations.UXEventsToken

        config.permissions.location =  loadedCapabilityLocation
        config.permissions.bluetooth =  loadedCapabilityBluetooth
        config.permissions.motion = loadedCapabilityMotion
        
        HabitAnalytics.shared.initialize(analyticsID: Configurations.AnalyticsID, analyticsAPIKey: Configurations.AnalyticsAPIToken, configuration: config, externalID: loadedExternalID ?? nil) { (statusCode) in
            debugPrint("Habit Analytics initialization code: " + String(statusCode) + " : " + HabitStatusCodes.getDescription(code: statusCode))
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
    }


}

