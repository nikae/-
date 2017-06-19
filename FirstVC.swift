//
//  FirstVC.swift
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
import AVFoundation


extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}

class FirstVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var backgroundView: UIView!
   
    @IBOutlet weak var b1: UIButton!
    @IBOutlet weak var b2: UIButton!
    @IBOutlet weak var b3: UIButton!
    @IBOutlet weak var b4: UIButton!
    @IBOutlet weak var b5: UIButton!
    
    func refreshTable(notification: NSNotification) {
        
//        if recivedInt == "1" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
//                self.b1.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//
//        } else if recivedInt == "2" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
//                self.b1.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
//                self.b2.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//
//        }  else if recivedInt == "3" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
//                self.b1.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
//                self.b2.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
//                self.b3.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//
//        }  else if recivedInt == "4" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
//                self.b1.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
//                self.b2.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
//                self.b3.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
//                self.b4.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//
//        }  else if recivedInt == "5" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
//                self.b1.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
//                self.b2.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
//                self.b3.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
//               self.b4.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
//               self.b5.setTitle("★", for: .normal)
//                AudioServicesPlaySystemSound (systemSoundID)
//            })
//
//        }

        let uId = FIRAuth.auth()?.currentUser?.uid
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(uId!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let rating = value?["rating"] as? Double ?? 5.0
            
            
            self.starsLabel.text = String(format: "%.01f", rating)
        }) { (error) in
            print(error.localizedDescription)
        }

        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//            self.b1.setTitle("", for: .normal)
//            self.b2.setTitle("", for: .normal)
//            self.b3.setTitle("", for: .normal)
//            self.b4.setTitle("", for: .normal)
//            self.b5.setTitle("", for: .normal)
//            
//            
//           
//        })

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: NSNotification.Name(rawValue: "a"), object: nil)
       
       
        
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            self.view.backgroundColor = nightModeColor
            imageView.layer.borderColor = nightModeColor.withAlphaComponent(0.8).cgColor
            backgroundView.backgroundColor = nightModeColor.withAlphaComponent(0.8)
            
        } else {
            //self.view.backgroundColor = .white
            
            imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
            
        }
        
        let uId = FIRAuth.auth()?.currentUser?.uid
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(uId!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
        
            let name = value?["name"] as? String ?? ""
            let pictureURL = value?["pictureURL"] as? String ?? ""
            let rating = value?["rating"] as? Double ?? 5.0
            
            self.nameLabel.text = name
            self.starsLabel.text = String(format: "%.01f", rating)
            
            if pictureURL != "" {
                self.getImage(pictureURL, imageView: self.imageView)
                self.getImage(pictureURL, imageView: self.backgroundImage)
            } else {
                self.imageView.image = UIImage(named: "IMG_7101")
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.borderWidth = 10
        //imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        
        //backgroundImage.image = UIImage(named: "IMG_7101")
       
        backgroundImage!.addBlurEffect()
        backgroundImage!.layer.cornerRadius = 15
        backgroundImage!.clipsToBounds = true
        backgroundView!.clipsToBounds = true
        backgroundView!.isUserInteractionEnabled = true
        
       
        
     
       
        backgroundView!.layer.cornerRadius = 15
        backgroundView!.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        backgroundView!.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        backgroundView!.layer.shadowOpacity = 1.0
        backgroundView!.layer.shadowRadius = 5
        backgroundView!.layer.masksToBounds = false
        
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver("a")
    }
    
    
    func calcRating( ratings: [Double] ) -> Double {
        var sum: Double = 0
        
        for index in ratings {
            sum += index
        }
        
        let count = ratings.count
        
        return sum / Double(count)
    }

    
    
    
    func getImage(_ url_str: String, imageView: UIImageView) {
        
        let url:URL = URL(string: url_str)!
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: {
            (
            data, response, error) in
            
            if data != nil
            {
                let image = UIImage(data: data!)
                
                if(image != nil)
                {
                    
                    DispatchQueue.main.async(execute: {
                        
                        imageView.image = image
                        imageView.alpha = 0
                        
                        UIView.animate(withDuration: 2.5, animations: {
                            imageView.alpha = 1.0
                        })
                        
                    })
                    
                }
                
            }
            
            
        })
        
        task.resume()
    }

    
    
    @IBAction func logout(_ sender: UIButton) {
        
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            self.present(vc, animated: true, completion: nil)
    }
    
    
//    func getUserDataFirebse() {
//        let uId = FIRAuth.auth()?.currentUser?.uid
//        let databaseRef = FIRDatabase.database().reference()
//        databaseRef.child("Users").child(uId!).observeSingleEvent(of: .value, with: { (snapshot) in
//          
//                let value = snapshot.value as? NSDictionary
//            
//                let userId = value?["userId"] as? String ?? ""
//                let name = value?["name"] as? String ?? ""
//                let pictureURL = value?["pictureURL"] as? String ?? ""
//                let createdAt = value?["createdAt"] as? String ?? ""
//                let ratings = value?["ratings"] as? [Rating] ?? []
//                let rating = value?["rating"] as? Double ?? 5
//                
//                self.user.createdAt = createdAt
//                self.user.name = name
//                self.user.pictureUrl = pictureURL
//                self.user.ratings = ratings
//                self.user.rating = rating
//                self.user.userId = userId
//            
//        }) { (error) in
//            print(error.localizedDescription)
//    }
//}
    
}
