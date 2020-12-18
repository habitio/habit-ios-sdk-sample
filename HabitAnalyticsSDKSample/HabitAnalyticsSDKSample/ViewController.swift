//
//  ViewController.swift
//  HabitAnalyticsSDKSample
//
//  Created by Ana Figueira on 31/07/2019.
//  Copyright © 2019 Habit Analytics. All rights reserved.
//

import UIKit
import HabitAnalytics
import CoreLocation
import CoreBluetooth
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate, HabitAnalyticsDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate
{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    

    private var centralManager : CBCentralManager?
    
    @IBOutlet weak var uiLbLoggedInStatus: UILabel!
    @IBOutlet weak var uiLoadingView: UIView!
   

    @IBOutlet var uiBtTrack: UIButton!
    

    @IBOutlet var uiTfExternalID: UITextField!
    
    @IBOutlet var uiBtInitialize: UIButton!
    
    @IBOutlet var uiBtSetExternalID: UIButton!
    

    
    @IBOutlet var uiSwitchLocation: UISwitch!
    @IBOutlet var uiBtRequestLocation: UIButton!
    
    @IBOutlet var uiSwitchBluetooth: UISwitch!
    @IBOutlet var uiBtRequestBluetooth: UIButton!
    
    @IBAction func uiBtSetExternalID_TouchUpInside(_ sender: UIButton) {
        
        if !uiTfExternalID.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        {
            StorageHelper.save(key: StorageHelper.key_externalID, value: uiTfExternalID.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            HabitAnalyticsSDK.shared.setExternalID(identifier: uiTfExternalID.text!.trimmingCharacters(in: CharacterSet.whitespaces)) { (code) in
                self.showAlert(title: String(code), message: HabitStatusCodes.getDescription(code: code))
            }
        }
    }
    
  
    
    @IBAction func uiSwitchLocation_ValueChanged(_ sender: UISwitch) {
        StorageHelper.save(key: StorageHelper.key_CapabilityLocation, value: sender.isOn)
        HabitAnalyticsSDK.shared.updatePermissions(permissionType: .location, permissionStatus: sender.isOn) { (code) in
            self.showAlert(title: String(code), message: HabitStatusCodes.getDescription(code: code))
        }
    }
    
    @IBAction func uiSwitchBluetooth_ValueChanged(_ sender: UISwitch) {
        StorageHelper.save(key: StorageHelper.key_CapabilityBluetooth, value: sender.isOn)
        HabitAnalyticsSDK.shared.updatePermissions(permissionType: .bluetooth, permissionStatus: sender.isOn) { (code) in
            self.showAlert(title: String(code), message: HabitStatusCodes.getDescription(code: code))
        }
    }
    

    
    var locationManager : CLLocationManager?
    
    @IBOutlet var uiBtSignOut: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    

    
    @IBAction func uiBtLogout_TouchUpInside(_ sender: Any) {
        logout()
    }
    
    @IBAction func uiBtTrack_TouchUpInside(_ sender: Any) {
        updateEvents() 
    }
    
    func setup()
    {
        
        self.uiTfExternalID.delegate = self
        self.uiLoadingView.isHidden = true
        
        //        changeButtonsState(isEnabled: false)
        
        DispatchQueue.main.async {
            
            self.uiLbLoggedInStatus.text = "Disabled"
            self.uiLbLoggedInStatus.textColor = UIColor.red
        }

        guard let loadedCapabilityBluetooth = StorageHelper.load(key: StorageHelper.key_CapabilityBluetooth) as! Bool? else { return }
        
        guard let loadedCapabilityLocation = StorageHelper.load(key: StorageHelper.key_CapabilityLocation) as! Bool? else { return }
        
        guard let loadedCapabilityMotion = StorageHelper.load(key: StorageHelper.key_CapabilityMotion) as! Bool? else { return }
        
        let loadedExternalID = StorageHelper.load(key: StorageHelper.key_externalID) as! String?
        if loadedExternalID != nil
        {
            self.uiTfExternalID.text = loadedExternalID!
            self.uiBtSetExternalID.isEnabled = false
        }
        else
        {
            self.uiBtSetExternalID.isEnabled = true
        }
        
        let config = Configuration()
        
        config.uxEventsConfig.token = Configurations.UXEventsToken
        
        config.capabilities.ux_events = true
        config.capabilities.bluetooth = loadedCapabilityBluetooth
        config.capabilities.location = loadedCapabilityLocation
        config.capabilities.motion = loadedCapabilityLocation
        config.permissions.location =  loadedCapabilityLocation
        config.permissions.bluetooth =  loadedCapabilityBluetooth
        config.permissions.motion = loadedCapabilityMotion
        
        
        uiSwitchLocation.isOn = config.capabilities.location
        uiSwitchBluetooth.isOn = config.capabilities.bluetooth
        
        
        self.uiLbNumberStoredEvents.text = "Stored Events: \(HabitAnalyticsSDK.shared.getNumberOfStoredEvents())"
        
        
        DispatchQueue.main.async {
            self.uiLbLoggedInStatus.text = "Enabled"
            self.uiLbLoggedInStatus.textColor = UIColor.green
            self.uiBtInitialize.isEnabled = false
            self.uiBtSignOut.isEnabled = true
            
        }
        
        HabitAnalyticsSDK.shared.initialize(analyticsID: Configurations.AnalyticsID, analyticsAPIKey: Configurations.AnalyticsAPIToken, configuration: config) { (code) in
            
            switch code
            {
                case HabitStatusCodes.HABIT_SDK_INITIALIZATION_SUCCESS,
                     HabitStatusCodes.HABIT_SDK_INITIALIZED_LOCATION_PERMISSIONS_REQUIRED:
                    
                    DispatchQueue.main.async {
                        
                        self.uiLbNumberStoredEvents.text = "Stored Events: \(HabitAnalyticsSDK.shared.getNumberOfStoredEvents())"
                        self.uiBtSignOut.isEnabled = true
                        self.uiLbLoggedInStatus.text = "Enabled"
                        self.uiLbLoggedInStatus.textColor = UIColor.green
                    }
                    break
                    
                case HabitStatusCodes.HABIT_SDK_NOT_INITIALIZED,
                     HabitStatusCodes.HABIT_SDK_INITIALIZATION_ERROR:
                    DispatchQueue.main.async {
                        
                        self.uiBtSignOut.isEnabled = false
                        self.uiLbLoggedInStatus.text = "Disabled"
                        self.uiLbLoggedInStatus.textColor = UIColor.red
                    }
                    
                default :
                    
                    break
            }
            self.showAlert(title: String(code), message: HabitStatusCodes.getDescription(code: code))
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func uiBtRequestLocation_TouchUpInside(_ sender: Any) {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
    
    @IBAction func uiBtRequestBluetooth_TouchUpInside(_ sender: Any) {
        centralManager = CBCentralManager(delegate: self, queue: .main)
        centralManager!.delegate = self
    }
    
        
    @IBAction func uiBtInitialize_TouchUpInside(_ sender: UIButton) {
        
        let config = Configuration()
                
   
        config.uxEventsConfig.token = Configurations.UXEventsToken
        config.capabilities.bluetooth = self.uiSwitchBluetooth.isOn
        config.capabilities.location = self.uiSwitchLocation.isOn
        config.capabilities.motion = self.uiSwitchLocation.isOn
        config.permissions.location =  self.uiSwitchLocation.isOn
        config.permissions.bluetooth =  self.uiSwitchBluetooth.isOn
        config.permissions.motion =  self.uiSwitchLocation.isOn
        
        StorageHelper.save(key: StorageHelper.key_CapabilityBluetooth, value: config.capabilities.bluetooth)
        StorageHelper.save(key: StorageHelper.key_CapabilityLocation, value: config.capabilities.location)
        StorageHelper.save(key: StorageHelper.key_CapabilityMotion, value: config.capabilities.motion)

        HabitAnalyticsSDK.shared.initialize(analyticsID: Configurations.AnalyticsID, analyticsAPIKey: Configurations.AnalyticsAPIToken, configuration: config) { (code) in
            switch code
            {
                case HabitStatusCodes.HABIT_SDK_INITIALIZATION_SUCCESS,
                     HabitStatusCodes.HABIT_SDK_INITIALIZED_LOCATION_PERMISSIONS_REQUIRED:
                    
                    self.uiLbNumberStoredEvents.text = "Stored Events: \(HabitAnalyticsSDK.shared.getNumberOfStoredEvents())"
                    self.uiBtSignOut.isEnabled = true
                    self.uiLbLoggedInStatus.text = "Enabled"
                    self.uiLbLoggedInStatus.textColor = UIColor.green
                    self.uiBtInitialize.isEnabled = false
                    break
                    
                case HabitStatusCodes.HABIT_SDK_NOT_INITIALIZED,
                     HabitStatusCodes.HABIT_SDK_INITIALIZATION_ERROR:
                    
                    self.uiBtSignOut.isEnabled = false
                    self.uiLbLoggedInStatus.text = "Disabled"
                    self.uiLbLoggedInStatus.textColor = UIColor.red
                    
                default :
                    
                    break
            }
            
            
            self.showAlert(title: String(code), message: HabitStatusCodes.getDescription(code: code))
        }
    }
    @IBOutlet var uiLbNumberStoredEvents: UILabel!
    
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func uiBtSignOut_TouchUpInside(_ sender: UIButton) {
        logout()
    }
    
    
    func logout()
    {
        HabitAnalyticsSDK.shared.logout { (code) in
            self.showAlert(title: String(code), message: HabitStatusCodes.getDescription(code: code))
        }
        
        StorageHelper.clearStorage()
        DispatchQueue.main.async {
            self.uiBtInitialize.isEnabled = true
            self.uiBtSignOut.isEnabled = false
            self.uiLbLoggedInStatus.text = "Disabled"
            self.uiLbLoggedInStatus.textColor = UIColor.red
        }
    }
    
    func updateEvents()
    {
         self.uiLbNumberStoredEvents.text = "Stored Events: \(HabitAnalyticsSDK.shared.getNumberOfStoredEvents())"
    }

    
    /// Delegate function that handles status changes in the SDK.
    /// This delegate is called when the user token has expired and a new valid authorization info must be set.
    ///
    /// - Parameter statusCode: Code that identifies the status change
    func HabitAnalyticsStatusChange(statusCode: HabitStatusCode) {
        switch statusCode {
            
        case HabitStatusCodes.SDK_DISABLED_CONTACT_SUPPORT:
            DispatchQueue.main.async {
                self.uiBtInitialize.isEnabled = true
                self.uiBtSignOut.isEnabled = false
                self.uiLbLoggedInStatus.text = "Disabled"
                self.uiLbLoggedInStatus.textColor = UIColor.red
            }
            
            break
        default:
             debugPrint("Habit status code: " + String(statusCode) + " : " + HabitStatusCodes.getDescription(code: statusCode))
        }
    }
}

