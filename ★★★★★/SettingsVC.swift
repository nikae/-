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

var viewIsDark = Bool()

class SettingsVC: UIViewController {
    
    @IBOutlet weak var ShareBtn: UIButton!
    @IBOutlet weak var nightModeBtn: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var desibleAccountMode: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
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
            nightModeBtn.setTitleColor(.white, for: .normal)
            infoBtn.setTitleColor(.white, for: .normal)
            ShareBtn.setTitleColor(.white, for: .normal)
            logOutBtn.setTitleColor(.white, for: .normal)
            desibleAccountMode.setTitleColor(.white, for: .normal)
            cancelBtn.setTitleColor(.white, for: .normal)
           
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
                    self.nightModeBtn.setTitleColor(.white, for: .normal)
                    self.infoBtn.setTitleColor(.white, for: .normal)
                    self.ShareBtn.setTitleColor(.white, for: .normal)
                    self.logOutBtn.setTitleColor(.white, for: .normal)
                    self.desibleAccountMode.setTitleColor(.white, for: .normal)
                    self.cancelBtn.setTitleColor(.white, for: .normal)
                    
                    self.view.backgroundColor = nightModeColor
                    viewIsDark = true
                    self.setNeedsStatusBarAppearanceUpdate()
                })
                
            nightModeDefaults.set(false, forKey: nightModeDefaults_Key)
            } else {
                
                UIView.animate(withDuration: 1.5, animations: {
                    self.nightModeBtn.setTitle("Dark Mode", for: .normal)
                    self.view.backgroundColor = .white
                    self.nightModeBtn.setTitleColor(buttonTextColorDark, for: .normal)
                    self.infoBtn.setTitleColor(buttonTextColorDark, for: .normal)
                    self.ShareBtn.setTitleColor(buttonTextColorDark, for: .normal)
                    self.logOutBtn.setTitleColor(buttonTextColorDark, for: .normal)
                    self.desibleAccountMode.setTitleColor(buttonTextColorDark, for: .normal)
                    self.cancelBtn.setTitleColor(buttonTextColorDark, for: .normal)
                    viewIsDark = false
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
            
            let message = "I have collected \(Int(rating))★"
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
        let alert = UIAlertController(title: "Information and help", message: "please choose following", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let Web = UIAlertAction(title: "Wisit web site", style: .default) { (action: UIAlertAction) in
            UIApplication.shared.openURL(NSURL(string: webLink)! as URL)
        }
        let Contact = UIAlertAction(title: "Contact / Report issue", style: .default) { (action: UIAlertAction) in
            UIApplication.shared.openURL(NSURL(string: "https://5starsapp.com/contact/")! as URL)
        }
        let TermsOfUse = UIAlertAction(title: "User License Agreement", style: .default) { (action: UIAlertAction) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "License_AgreementVC") as! License_AgreementVC
            self.present(vc, animated: true, completion: nil)
        }
        let privacyPolicy = UIAlertAction(title: "Privacy policy", style: .default) { (action: UIAlertAction) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
            self.present(vc, animated: true, completion: nil)
        }

        alert.addAction(cancel)
        alert.addAction(Web)
        alert.addAction(Contact)
        alert.addAction(TermsOfUse)
        alert.addAction(privacyPolicy)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func nightModeHit(_ sender: UIButton) {
        launchBool = !launchBool
    }

    @IBAction func logOutHit(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: "Do you want to log out?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
        
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
            
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
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
        
        self.dismiss(animated: true, completion: nil)
    }
   
}
