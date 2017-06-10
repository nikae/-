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



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

  

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        FIRApp.configure()
        
        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(notification:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        
                if FIRAuth.auth()?.currentUser != nil {
                    FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                        if user != nil {
                            
                    self.window?.rootViewController = self.storyboard.instantiateViewController(withIdentifier: "ViewController")
                            
                        } else {
                            print("No user is signed in.")
                }
            
            }
        }
 
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    
        return true
       }
    
    @available(iOS 10.0, *)
    func userNotificationCenet(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, wihCompiletionHandler compilationHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        compilationHandler(.alert)
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handler = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation:options[UIApplicationOpenURLOptionsKey.annotation])
        return handler
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        print("Message")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("TTT: \(token)")
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


    func tokenRefreshNotification(notification: NSNotification) {
        let refreshToken = FIRInstanceID.instanceID().token()
        print("Instance ID: \(String(describing: refreshToken))")
        conectToFMC()
    }
    
    func conectToFMC(){
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Mesiging system error: \(String(describing: error))")
            } else {
                print("Message connect succes")
            }
        }
    }
    
}

