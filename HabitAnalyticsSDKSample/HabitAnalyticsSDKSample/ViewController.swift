//
//  ViewController.swift
//  HabitAnalyticsSDKSample
//
//  Created by Ana Figueira on 31/07/2019.
//  Copyright © 2019 Habit Analytics. All rights reserved.
//

import UIKit
import HabitAnalytics

class ViewController: UIViewController, UITextFieldDelegate, HabitAnalyticsDelegate {

    @IBOutlet weak var uiLbLoggedInStatus: UILabel!
    @IBOutlet weak var uiLoadingView: UIView!
    
    @IBOutlet weak var uiTfName: UITextField!
    @IBOutlet weak var uiTfEmail: UITextField!
    @IBOutlet weak var uiTfPassword: UITextField!
    
    @IBOutlet weak var uiBtCreateAccount: UIButton!
    @IBOutlet weak var uiBtLogin: UIButton!
    @IBOutlet weak var uiBtLogout: UIButton!
    @IBOutlet weak var uiBtTrack: UIButton!
    
    private var userAuthInfo : NSDictionary?
    
    private var isUserLoggedIn : Bool = false {
        didSet
        {
            DispatchQueue.main.async {
                
                if self.isUserLoggedIn
                {
                    self.uiLbLoggedInStatus.text = "Yes"
                    self.uiLbLoggedInStatus.textColor = UIColor.green
                    self.uiBtCreateAccount.isEnabled = false
                    self.uiBtLogin.isEnabled = false
                    self.uiBtLogout.isEnabled = true
                    self.uiBtTrack.isEnabled = true
                }
                else
                {
                    self.uiLbLoggedInStatus.text = "No"
                    self.uiLbLoggedInStatus.textColor = UIColor.red
                    self.uiBtCreateAccount.isEnabled = true
                    self.uiBtLogin.isEnabled = true
                    self.uiBtLogout.isEnabled = false
                    self.uiBtTrack.isEnabled = false
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
       
    }
    
    @IBAction func uiBtCreateAccount_TouchUpInside(_ sender: Any) {
        self.uiLoadingView.isHidden = false
        if !uiTfName.text!.isEmpty && !uiTfEmail.text!.isEmpty && !uiTfPassword.text!.isEmpty
        {
            createAccount(name: uiTfName.text!, email: uiTfEmail.text!, password: uiTfPassword.text!)
            
        }
        else
        {
            showAlert(title: "", message: "Please make sure all the required fields are properly filled")
              self.uiLoadingView.isHidden = true
        }
    }
    
    @IBAction func uiBtLogin_TouchUpInside(_ sender: Any) {
        
        self.uiLoadingView.isHidden = false
        if !uiTfEmail.text!.isEmpty && !uiTfPassword.text!.isEmpty
        {
            login(email: uiTfEmail.text!, password: uiTfPassword.text!)
            
        }
        else
        {
            showAlert(title: "", message: "Please make sure all the required fields are properly filled")
            self.uiLoadingView.isHidden = true
        }
    }
    
    @IBAction func uiBtLogout_TouchUpInside(_ sender: Any) {
        logout()
    }
    
    @IBAction func uiBtTrack_TouchUpInside(_ sender: Any) {
        track()
    }
    
    func setup()
    {
        uiTfName.delegate = self
        uiTfEmail.delegate = self
        uiTfPassword.delegate = self
        uiTfPassword.passwordRules = nil
      
        self.uiLoadingView.isHidden = true
        
        guard let loadedAuthInfo = Storage.loadAuthInfo() else
        {
            self.isUserLoggedIn = false
            return
        }
        
        self.userAuthInfo = loadedAuthInfo
        self.isUserLoggedIn = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    func login(email: String, password: String)
    {
        Authentication.signIn(email: email, password: password) { (jsonResponse, error) in
            if error != nil
            {
                self.showAlert(title: "Error logging in", message: String(error!.code))
                self.isUserLoggedIn = false
                DispatchQueue.main.async {
                    self.uiLoadingView.isHidden = true
                }
                return
            }
            
            if jsonResponse != nil
            {
                Storage.storeAuthInfo(jsonResponse!)
                self.userAuthInfo = jsonResponse
                
                HabitAnalytics.shared.setAuthorization(authInfo:self.userAuthInfo!, completion: { (statusCode) in
                    switch statusCode
                    {
                    case HabitStatusCodes.HABIT_SDK_NOT_INITIALIZED:
                        HabitAnalytics.shared.initialize(namespace: Configurations.Namespace, analyticsInfo: nil, authInfo: self.userAuthInfo, completion: { (statusCode) in
                            if statusCode != HabitStatusCodes.HABIT_SDK_INITIALIZATION_SUCCESS
                            {
                                self.showAlert(title: "Login", message: "Error setting user!")
                                self.isUserLoggedIn = false
                            }
                            else
                            {
                                self.showAlert(title: "Login", message: "User logged in with success!")
                                self.isUserLoggedIn = true
                            }
                        })
                        break
                    
                    case HabitStatusCodes.USER_INITIALIZATION_SUCCESS:
                        self.showAlert(title: "Login", message: "User logged in with success!")
                        self.isUserLoggedIn = true
                        break
                    
                    case HabitStatusCodes.USER_INITIALIZATION_ERROR:
                        self.showAlert(title: "Login", message: "Error setting user!")
                        self.isUserLoggedIn = false
                        break
                    default:
                        
                        break
                    }
                    DispatchQueue.main.async {
                        self.uiLoadingView.isHidden = true
                    }
                })
            }
        }
        
    }
    
    func createAccount(name: String, email: String, password: String)
    {
        Authentication.createAccount(name: name, email: email, password: password) { (jsonResponse, error) in
            if error != nil
            {
                self.showAlert(title: "Error creating account", message: String(error!.code))
            }
            
            if jsonResponse != nil
            {
                self.showAlert(title: "Create account", message: "Account created with success!")
            }
            
            DispatchQueue.main.async {
                self.uiLoadingView.isHidden = true
            }
        }
    }
    
    
    func logout()
    {
        Storage.deleteStoredInfo()
        HabitAnalytics.shared.logout { (statusCode) in
            self.isUserLoggedIn = false
        }
        
    }
    
    func track()
    {
        let resultString = HabitStatusCodes.getDescription(code: HabitAnalytics.shared.track(eventName: "HabitAnalyticsSDKSampleEvent", properties: nil))
        self.showAlert(title: "Track", message: resultString)
    }

    func showAlert(title: String, message: String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /// Delegate function that handles status changes in the SDK.
    /// This delegate is called when the user token has expired and a new valid authorization info must be set.
    ///
    /// - Parameter statusCode: Code that identifies the status change
    func HabitAnalyticsStatusChange(statusCode: HabitStatusCode) {
        switch statusCode {
            
        case HabitStatusCodes.SET_VALID_AUTHENTICATION_INFO:
            guard let refreshToken = Storage.loadAuthInfo()?["refresh_token"] as? String else
            {
                debugPrint("No refresh token available to obtain new token")
                self.logout()
                showAlert(title: "Error refreshing token", message: "User is now logged out")
                return
            }
            
            Authentication.refreshToken(refreshToken: refreshToken) { (result, error) in
                if error != nil
                {
                    debugPrint(error!)
                    HabitAnalytics.shared.logout(completion: { (code) in
                        self.isUserLoggedIn = false
                        Storage.deleteStoredInfo()
                    })
                }
                
                if result != nil
                {
                    Storage.storeAuthInfo(result!)
                    HabitAnalytics.shared.setAuthorization(authInfo: result!, completion: { (statusCode) in
                        debugPrint("HabitSDK: " + String(statusCode) + " : " + HabitStatusCodes.getDescription(code: statusCode))
                    })
                }
            }
            
        default:
             debugPrint("Habit status code: " + String(statusCode) + " : " + HabitStatusCodes.getDescription(code: statusCode))
        }
    }
}

