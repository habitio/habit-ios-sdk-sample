//
//  Authentication.swift
//  HabitAnalyticsSDKSample
//
//  Created by Ana Figueira on 01/08/2019.
//  Copyright © 2019 Habit Analytics. All rights reserved.
//

import Foundation
import HabitAnalytics

class Authentication
{
    
    
    /// Function that creates a new account
    ///
    /// - Parameters:
    ///   - name: Name of the user
    ///   - email: Email
    ///   - password: Password
    ///   - completion: completion handler
    static func createAccount(name : String, email : String, password: String, completion: @escaping (_ response: NSDictionary?, _ error: NSError?) -> Void)
    {
        let url = URL(string: Endpoints.SignUp())!
        
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json = [
            "appId": Configurations.Namespace,
            "name": name,
            "email": email,
            "device": "iphone",
            "password": password
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            
            if error != nil
            {
                completion(nil, error as NSError?)
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            switch statusCode!
            {
                case 200:
                    do {
                        guard let data = data else {
                            completion(nil, NSError(domain: "Error creating account", code: -1, userInfo: nil))
                            break
                        }
                        
                        guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                            completion(nil, NSError(domain: "Error creating account", code: -1, userInfo: nil))
                            return
                        }
                        
                        completion(jsonResponse, nil)
                        
                        } catch let error as NSError {
                            completion(nil, error)
                        }
                    break
                
                default:
                    completion(nil, NSError(domain: "Error creating account", code: statusCode!, userInfo: nil))
                    break
                }
            
             }
        
            task.resume()
    }
    
    
    /// Function used to authenticate a user
    ///
    /// - Parameters:
    ///   - email: Email
    ///   - password: Password
    ///   - completion: Completion handler
    static func signIn(email : String, password: String, completion: @escaping (_ response: NSDictionary?, _ error: NSError?) -> Void)
    {
        let url = URL(string: Endpoints.SignIn(clientId: Configurations.ClientID, username: email, password: password))!
        
        URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                completion(nil, error as NSError?)
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            switch statusCode!
            {
            case 200:
                do {
                    guard let data = data else {
                        completion(nil, NSError(domain: "Login error", code: -1, userInfo: nil))
                        break
                    }
                    
                    guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                        completion(nil, NSError(domain: "Login error", code: -1, userInfo: nil))
                        return
                    }
                    
                    completion(jsonResponse, nil)
                    
                } catch let error as NSError {
                    completion(nil, error)
                }
                
                
                break
                
            default:
                completion(nil, NSError(domain: "Login error", code: -1, userInfo: nil))
                break
            }
            
            }.resume()
    }
    
    
    
    /// Function used to refresh a user token. Tokens expire and it's necessary to negotiate a new one using the refresh_token received when signing in.
    ///
    /// - Parameters:
    ///   - refreshToken: Refresh token
    ///   - completion: completion handler
    static func refreshToken(refreshToken: String, completion: @escaping (_ response: NSDictionary?, _ error: NSError?) -> Void)
    {
        let url = URL(string: Endpoints.RefreshToken(clientId: Configurations.ClientID, refreshToken: refreshToken))!
     
            URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil
                {
                    completion(nil, error as NSError?)
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                switch statusCode!
                {
                case 200:
                    do {
                        guard let data = data else {
                            completion(nil, NSError(domain: "Error Refreshing Token", code: -1, userInfo: nil))
                            break
                        }
                        
                        guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                            completion(nil, NSError(domain: "Error Refreshing Token", code: -1, userInfo: nil))
                            return
                        }
                        
                        completion(jsonResponse, nil)
                        
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                    
                    break
                    
                default:
                    completion(nil, NSError(domain: "Error Refreshing Token", code: -1, userInfo: nil))
                    break
                }
                
            }.resume()
    }
    
}
