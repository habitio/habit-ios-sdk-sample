//
//  Endpoints.swift
//  HabitAnalyticsSDKSample
//
//  Created by Ana Figueira on 02/08/2019.
//  Copyright © 2019 Habit Analytics. All rights reserved.
//

class Endpoints {
    
    class func SignIn(clientId: String, username: String, password: String) -> String
    {
        let escapedUsername : String = username.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let escapedPassword : String = password.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
        return Configurations.AuthHost + "/v3/auth/authorize?client_id=" + clientId + "&response_type=password&scope=application,user&username=" + escapedUsername + "&password=" + escapedPassword
    }
    
    class func SignUp() -> String { return Configurations.AuthHost + "/v3/legacy/account" }
    
    class func RefreshToken(clientId: String, refreshToken: String) -> String { return Configurations.AuthHost + "/v3/auth/exchange?client_id=" + clientId + "&refresh_token=" + refreshToken + "&grant_type=password"}
    
}
