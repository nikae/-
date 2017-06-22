//
//  LogInVC.swift
//  ★★★★★
//
//  Created by Nika on 4/24/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import CoreLocation

class LogInVC: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate {
    
    var imgURLString = ""
    var userName = ""
    var location: [String : CLLocationDegrees]!
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        
        view.addSubview(loginButton)
        
        loginButton.frame = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 50)
        loginButton.center = view.center
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.first!
        location = ["lat" : loc.coordinate.latitude, "long" : loc.coordinate.longitude]
        coordinate1 = loc
        print("LOCATION: \(location)")
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        print("Loged Out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        showUserInfo()
    }
    
    func showUserInfo() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                    print("error with FB user:", error ?? "No error")
                    return
                }
                
                print("Saccesfuly loged in:", user ?? "annonymus")
                
                if FIRAuth.auth()?.currentUser != nil {
                    let uid = FIRAuth.auth()?.currentUser?.uid
                    let databaseRef = FIRDatabase.database().reference()
                    databaseRef.child("Users").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                        if snapshot.hasChild(uid!){
                            print("room exist")
                            self.locationManager.stopUpdatingLocation()
                            databaseRef.child("Users/\(uid!)/isActive").setValue(true)
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                            self.present(vc!, animated: true, completion: nil)
                        }else{
                            print("false room doesn't exist")
                            self.saveUserInDataBase()
                            self.locationManager.stopUpdatingLocation()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                            self.present(vc!, animated: true, completion: nil)
                        }
                    })
                }
            })
        
//        func showNextController() {
//            let databaseRef = FIRDatabase.database().reference()
//            let uid = FIRAuth.auth()?.currentUser?.uid
//            var usersToSend = [User]()
//            //MARK: --> Get users from database
//            if coordinate1 != nil {
//                databaseRef.child("Users").observe(.childAdded , with: { (snapshot) in
//                    let value = snapshot.value as? NSDictionary
//                    
//                    let userID = value?["userID"] as? String ?? ""
//                    let name = value?["name"] as? String ?? ""
//                    let pictureURL = value?["pictureURL"] as? String ?? ""
//                    let createdAt = value?["createdAt"] as? String ?? ""
//                    let rating = value?["rating"] as? Double ?? 5.0
//                    let ratings = value?["ratings"] as? [String : AnyObject] ?? [:]
//                    let locations = value?["Location"] as? [String : AnyObject] ?? [:]
//                    let isActive = value?["isActive"] as? Bool
//                    
//                    if locations.count != 0 {
//                        if isActive != false {
//                            var usersCordinate: CLLocation!
//                            let latitude = locations["lat"] as! CLLocationDegrees
//                            let longitude = locations["long"] as! CLLocationDegrees
//                            usersCordinate = CLLocation(latitude: latitude, longitude: longitude)
//                            
//                            let distanceInMeters = usersCordinate.distance(from: coordinate1) // result is in meters
//                            let distanceInMiles = distanceInMeters * 0.000621371192 //In Miles
//                            
//                            if userID != uid {
//                                var rArray = [Rating]()
//                                for i in ratings {
//                                    let creator = i.value["creator"] as! String
//                                    let createdAt = i.value["createdAt"] as! String
//                                    let value = i.value["value"] as! Double
//                                    
//                                    rArray.append(Rating(creator: creator, createdAt: createdAt, value: value))
//                                }
//                                
//                                if usersToSend.count < 200 {
//                                    usersToSend.append(User(userId: userID, name: name, pictureUrl: pictureURL, createdAt: createdAt, ratings: rArray, rating: rating, distance: distanceInMiles))
//                                    usersToSend = usersToSend.sorted(by: {$0.distance < $1.distance})
//                                }
//                                
//                                let destination = SecondVC(nibName: "SecondVC", bundle: Bundle.main)
//                                destination.users = usersToSend
//                                self.show(destination, sender: self)
//                            }
//                        }
//                    }
//                }) { (error) in
//                    print(error.localizedDescription)
//                }
//            }
//
//            
//            
//            
//        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request", err ?? "")
                return
            }
            
            let data:[String: AnyObject] = result as! [String : AnyObject]
            let userFBId = data["id"]  as AnyObject
            let userFBId_String = "\(userFBId)"
             self.userName = data["name"] as! String
            print(self.userName)
            
            if (userFBId_String != "") {
                self.imgURLString = "http://graph.facebook.com/" + userFBId_String + "/picture?width=1000" //type=normal
            }
        }
    }
    

    func saveUserInDataBase() {
        
        let databaseRef = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy h:mm a"
        let result = formatter.string(from: date)
        
        let userId = userID
        let name = self.userName
        let pictureURL = self.imgURLString
        let createdAt = result
        let rating: Double = 5
        let isActive: Bool = true
        let loc = location
        
        let ratings: Dictionary<String, AnyObject> = [:]
        
        
        let userData: Dictionary<String, AnyObject> = ["userID" : userId as AnyObject,
                                                       "name" : name as AnyObject,
                                                       "pictureURL" : pictureURL as AnyObject,
                                                       "createdAt" : createdAt as AnyObject,
                                                       "ratings" : ratings as AnyObject,
                                                       "rating" : rating as AnyObject,
                                                       "isActive": isActive as AnyObject,
                                                       "Location" : loc as AnyObject]
        
        databaseRef.child("Users/\(userId!)").setValue(userData)
        
    }
}







































