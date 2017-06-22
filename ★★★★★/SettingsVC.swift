//
//  SettingsVC.swift
//  ★★★★★
//
//  Created by Nika on 6/14/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import Firebase



class SettingsVC: UIViewController {
    
    @IBOutlet weak var ShareBtn: UIButton!
    @IBOutlet weak var nightModeBtn: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var desibleAccountMode: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var viewIsDark = Bool()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        //let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        
        if viewIsDark == true {
            return .lightContent
        } else {
            return .default
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewShape(view: ShareBtn)
        viewShape(view: nightModeBtn)
        viewShape(view: logOutBtn)
        viewShape(view: desibleAccountMode)
        
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            view.backgroundColor = nightModeColor
            nightModeBtn.setTitle("Light Mode", for: .normal)
            launchBool = true
           
        } else {
            view.backgroundColor = .white
            nightModeBtn.setTitle("Dark Mode", for: .normal)
        }
   
    }
    
    var launchBool: Bool = false {
        didSet {
            if launchBool == true {
                
                UIView.animate(withDuration: 1.5, animations: {
                    
                    self.nightModeBtn.setTitle("Light Mode", for: .normal)
                    self.view.backgroundColor = nightModeColor
                    self.viewIsDark = true
                    self.setNeedsStatusBarAppearanceUpdate()
                })
                
            nightModeDefaults.set(false, forKey: nightModeDefaults_Key)
            } else {
                
                UIView.animate(withDuration: 1.5, animations: {
                    self.nightModeBtn.setTitle("Dark Mode", for: .normal)
                    self.view.backgroundColor = .white
                    self.viewIsDark = false
                    self.setNeedsStatusBarAppearanceUpdate()

                })
                
                nightModeDefaults.set(true, forKey: nightModeDefaults_Key)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MemoryWarning")
    }
    
    
    @IBAction func shareHit(_ sender: Any) {
       
        let uId = FIRAuth.auth()?.currentUser?.uid
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(uId!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let rating = value?["rating"] as? Double ?? 5.0
            
//Needs to have added link and text has to be changed
            let message = "My ★★★★★ rating is \( String(format: "%.01f", rating))★."
            if let link = NSURL(string: "\(webLink)")
            {
                let objectsToShare = [message,link] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }

        

    }
    
    
    @IBAction func infoHit(_ sender: UIButton) {
        print("T&C goes here")
    }
    
    @IBAction func nightModeHit(_ sender: UIButton) {
        launchBool = !launchBool
    }

    @IBAction func logOutHit(_ sender: UIButton) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let manager = FBSDKLoginManager()
                manager.logOut()
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC") as! LogInVC
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func desibleAccountHit(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Do you want to disable your account?", message: "Disabled accounts cannot be searched or viewed by other users.", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continu = UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction) in
            
            let alert = UIAlertController(title: "Disabling your account", message: "Your account will be disabled but can be reactivated by logging in.", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let ok = UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction) in
                let uid = FIRAuth.auth()?.currentUser?.uid
                let databaseRef = FIRDatabase.database().reference()
                databaseRef.child("Users/\(uid!)/isActive").setValue(false)
                
                
                if FIRAuth.auth()?.currentUser != nil {
                    do {
                        try FIRAuth.auth()?.signOut()
                        let manager = FBSDKLoginManager()
                        manager.logOut()
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC") as! LogInVC
                self.present(vc, animated: true, completion: nil)
                
            })
            
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        })
        
        alert.addAction(continu)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func dismissVIewHit(_ sender: UIButton) {
        //self.view.removeFromSuperview()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        present(vc, animated: true, completion: nil)
    }
   
}
