//
//  AppDelegate.swift
//  ★★★★★
//
//  Created by Nika on 4/3/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import Firebase
import UserNotifications
import CoreLocation

var window: UIWindow?
let gcmMessageIDKey = "gcm.message_id"
var a = String()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
  
    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        //!!! TEST THIS compear to pre
        application.registerForRemoteNotifications()
        
        if FIRAuth.auth()?.currentUser != nil {
            FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                if user != nil {
                    if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
                        self.locationManager.requestAlwaysAuthorization()
                    }
                    
                    if CLLocationManager.locationServicesEnabled() {
                        self.locationManager.delegate = self
                        self.locationManager.distanceFilter = 20
                        self.locationManager.startUpdatingLocation()
                        coordinate1 = self.locationManager.location
                    }
                    
                    self.window?.rootViewController = self.storyboard.instantiateViewController(withIdentifier: "ViewController")
                } else {
                    print("No user is signed in.")
                }
            }
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handler = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation:options[UIApplicationOpenURLOptionsKey.annotation])
        return handler
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        if let token = FIRInstanceID.instanceID().token() {
            let uid = FIRAuth.auth()?.currentUser?.uid
            if uid != nil {
                let databaseRef = FIRDatabase.database().reference()
                databaseRef.child("Users/\(uid!)/token").setValue(token)
            }
        }
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//!!!MARK --> Figoure Out Location. (CAN BE TURNED OFF) - (Or Test well gah )
        locationManager.delegate = self
        locationManager.distanceFilter = 20
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.beginBackgroundTask{}
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.beginBackgroundTask{}
    }

    func applicationWillTerminate(_ application: UIApplication) {
        application.beginBackgroundTask{}
    }
    
    // MARK --> Location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            locationManager.requestAlwaysAuthorization()
            break
        case .denied:
            locationManager.requestAlwaysAuthorization()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.first!
        sendLocationToServer(location: loc)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error updating location:" + error.localizedDescription)
    }
    
    func sendLocationToServer(location: CLLocation) {
        var backgroundTask = UIBackgroundTaskIdentifier()
        backgroundTask = UIApplication.shared.beginBackgroundTask { () -> Void in
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let loc = ["lat" : location.coordinate.latitude, "long" : location.coordinate.longitude]
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users/\(uid!)/Location").setValue(loc)
        
        if (backgroundTask != UIBackgroundTaskInvalid) {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
    
    //MARK --> End Location

}




//MARK --> Message handling
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(notification.request.content.title)
        recivedInt = notification.request.content.title
        
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
        print("Heyyyyyy")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "a"), object: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
//        print("Heyyyyyy")
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "a"), object: nil)
//        completionHandler()
    }
}



//MARK --> END Message handling

extension AppDelegate : FIRMessagingDelegate {
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("IDK")
    }

    //MARK --> Refresh token
    func messaging(_ messaging: FIRMessaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: FIRMessaging, didReceive remoteMessage: FIRMessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
