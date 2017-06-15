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
    
    @IBOutlet weak var nightModeBtn: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var desibleAccountMode: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

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
                })
                
            nightModeDefaults.set(false, forKey: nightModeDefaults_Key)
            } else {
                
                UIView.animate(withDuration: 1.5, animations: {
                    self.nightModeBtn.setTitle("Dark Mode", for: .normal)
                    self.view.backgroundColor = .white

                })
                
                nightModeDefaults.set(true, forKey: nightModeDefaults_Key)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MemoryWarning")
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
        print("Account Desibility Goes here")
    }
    
    @IBAction func dismissVIewHit(_ sender: UIButton) {
        //self.view.removeFromSuperview()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        present(vc, animated: true, completion: nil)
    }
   
}
