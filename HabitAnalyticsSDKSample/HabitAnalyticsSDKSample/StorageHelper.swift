//
//  StorageHandler.swift
//  HabitAnalyticsSDKSample
//
//  Created by Ana Figueira on 01/09/2020.
//  Copyright © 2020 Habit Analytics. All rights reserved.
//

import Foundation

class StorageHelper : NSObject
{
    static let key_externalID = "externalID"
    static let key_CapabilityBluetooth = "CapabilityBluetooth"
    static let key_CapabilityLocation = "CapabilityLocation"
    static let key_CapabilityMotion = "CapabilityMotion"
    static let key_CapabilityUXEvents = "CapabilityUXEvents"
    
    
    //
    //  Activity
    //
    
    static func save(key: String, value : Any)
    {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    static func load(key: String) -> Any?
    {
        return UserDefaults.standard.object(forKey: key)
    }
    
    static func remove(key: String)
    {
        if (UserDefaults.standard.object(forKey: key)) != nil
        {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    
    static func clearStorage()
    {
        let userDefaults = UserDefaults.standard;
        
        userDefaults.removeObject(forKey: key_CapabilityBluetooth)
        userDefaults.removeObject(forKey: key_CapabilityLocation)
        userDefaults.removeObject(forKey: key_CapabilityMotion)
        userDefaults.removeObject(forKey: key_externalID)
        
        userDefaults.synchronize()
        
    }
}
