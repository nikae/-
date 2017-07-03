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

class LogInVC: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate,UIGestureRecognizerDelegate {
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var agrLabel: UILabel!
    @IBOutlet var taptap: UITapGestureRecognizer!
    
    var imgURLString = ""
    var userName = ""
    var location: [String : CLLocationDegrees]!
    
    var locationManager = CLLocationManager()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let loginButton = FBSDKLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        taptap.delegate = self
        
        agrLabel.adjustsFontSizeToFitWidth = true
        
        view.addSubview(loginButton)
        loginButton.isUserInteractionEnabled = false
        
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
        
        loginButton.isHidden = true
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(self.activityIndicator)
        
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.showUserInfo()
        
       
    }
    
    func showUserInfo() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
         print("facebook log in authorized")
        
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
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                            self.present(vc!, animated: true, completion: nil)
                        }else{
                            print("false room doesn't exist")
                            self.saveUserInDataBase()
                            self.locationManager.stopUpdatingLocation()
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                            self.present(vc!, animated: true, completion: nil)
                        }
                    })
                }
            })
        

        
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
    
    var launchBool: Bool = false {
        didSet {
            if launchBool == true {
                let alert = UIAlertController(title: "Agreement", message: "By clicking \("Agree"), you agree to our User License Agreement and Privacy Policy", preferredStyle: .actionSheet)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
                    self.launchBool = false
                }

                let Agree = UIAlertAction(title: "Agree", style: .default) { (action: UIAlertAction) in
                    self.checkBtn.setTitle("☑︎", for: .normal)
                    self.loginButton.isUserInteractionEnabled = true
                    self.loginButton.backgroundColor = .blue
                }
                
                let privacyPolicy = UIAlertAction(title: "Privacy policy", style: .default) { (action: UIAlertAction) in
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
                    self.present(vc, animated: true, completion: nil)
                    self.launchBool = false
                }
                
                let LicenseAgreement = UIAlertAction(title: "User License Agreement", style: .default) { (action: UIAlertAction) in
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "License_AgreementVC") as! License_AgreementVC
                    self.present(vc, animated: true, completion: nil)
                    self.launchBool = false
                }
                
                alert.addAction(cancel)
                alert.addAction(LicenseAgreement)
                alert.addAction(privacyPolicy)
                alert.addAction(Agree)
                
                present(alert, animated: true, completion: nil)
             } else {
              loginButton.isUserInteractionEnabled = false
                checkBtn.setTitle("◻︎", for: .normal)
                loginButton.setTitle("please", for: .normal)
            }
        }
    }
    @IBAction func tapToAgree(_ sender: UITapGestureRecognizer) {
        print("tap")
        launchBool = !launchBool
    }
    
    @IBAction func testButtonHit(_ sender: UIButton) {
        launchBool = !launchBool
    }
}







































