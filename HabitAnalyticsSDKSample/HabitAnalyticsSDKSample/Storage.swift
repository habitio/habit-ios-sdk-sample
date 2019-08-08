//
//  Storage.swift
//  HabitAnalyticsSDKSample
//
//  Created by Ana Figueira on 01/08/2019.
//  Copyright © 2019 Habit Analytics. All rights reserved.
//

import Foundation


/// Helper class used to store user information as a cache mechanism so the user remains logged in.
class Storage
{
    static let key_auth_info = "auth_info"
    
    static func storeAuthInfo(_ authInfo : NSDictionary)
    {
        let userDefaults = UserDefaults.standard;
        
        userDefaults.set(authInfo, forKey: key_auth_info)
        
        userDefaults.synchronize()
    }
    
    static func loadAuthInfo() -> NSDictionary?
    {
        let userDefaults = UserDefaults.standard;
        
        if((userDefaults.object(forKey: key_auth_info)) != nil)
        {
            return userDefaults.object(forKey: key_auth_info) as? NSDictionary
        }
        
        return nil
    }
    
    static func deleteStoredInfo()
    {
        let userDefaults = UserDefaults.standard;
        
        userDefaults.removeObject(forKey: key_auth_info)
        
        userDefaults.synchronize()
    }
}
