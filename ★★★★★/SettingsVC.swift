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
      
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MemoryWarning")
    }
    
    @IBAction func infoHit(_ sender: UIButton) {
        print("T&C goes here")
    }
    
    @IBAction func nightModeHit(_ sender: UIButton) {
        print("NightModeGoes here")
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
