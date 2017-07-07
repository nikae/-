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
import SDWebImage


extension UIImageView
{
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
    func addDarkBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }

}

class FirstVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starStarLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var meniuBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
   
    @IBOutlet weak var b1: UIButton!
    @IBOutlet weak var b2: UIButton!
    @IBOutlet weak var b3: UIButton!
    @IBOutlet weak var b4: UIButton!
    @IBOutlet weak var b5: UIButton!
    
    func refreshTable(notification: NSNotification) {
        let uId = FIRAuth.auth()?.currentUser?.uid
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(uId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let rating = value?["rating"] as? Double ?? 5.0
            
            self.starsLabel.text = String(format: "%.01f", rating)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: NSNotification.Name(rawValue: "a"), object: nil)
        
        let uId = FIRAuth.auth()?.currentUser?.uid
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child(uId!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
        
            let name = value?["name"] as? String ?? ""
            let pictureURL = value?["pictureURL"] as? String ?? ""
            let rating = value?["rating"] as? Double ?? 5.0
            
            self.nameLabel.text = name
            self.starsLabel.text = "\(String(format: "%.01f", rating))★" //"\(Int(rating))★"
            self.starsLabel.adjustsFontSizeToFitWidth = true
            
            if pictureURL != "" {
                    self.imageView.sd_setImage(with: URL(string: pictureURL), placeholderImage: UIImage(named: "creen Shot 2017-06-15 at 9.35.49 AM"))
                    self.backgroundImage.sd_setImage(with: URL(string: pictureURL), placeholderImage: UIImage(named: "creen Shot 2017-06-15 at 9.35.49 AM"))
                self.imageView.setShowActivityIndicator(true)
                self.imageView.setIndicatorStyle(.gray)
                
            } else {
                self.imageView.image = UIImage(named: "Screen Shot 2017-06-15 at 9.35.49 AM")
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        nameLabel.adjustsFontSizeToFitWidth = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.borderWidth = 10
        
        backgroundImage!.addBlurEffect()
        backgroundImage!.layer.cornerRadius = 15
        backgroundImage!.clipsToBounds = true
        
        backgroundView!.clipsToBounds = true
        backgroundView!.isUserInteractionEnabled = true
        backgroundView!.layer.cornerRadius = 15
        backgroundView!.layer.masksToBounds = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver("a")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            
            self.view.backgroundColor = nightModeColor
            imageView.layer.borderColor = nightModeColor.withAlphaComponent(0.8).cgColor
            backgroundView.backgroundColor = nightModeColor.withAlphaComponent(0.8)
            
            nameLabel.textColor = .white
            starsLabel.textColor = .white
            //starStarLabel.textColor = .white
            meniuBtn.setTitleColor(.gray, for: .normal)
            
        } else {
            self.view.backgroundColor = .white
            imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
            backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            
            nameLabel.textColor = buttonTextColorDark
            starsLabel.textColor = buttonTextColorDark
            //starStarLabel.textColor = buttonTextColorDark
            meniuBtn.setTitleColor(buttonTextColorDark, for: .normal)
        }

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
        
        let task = session.dataTask(with: url, completionHandler: {( data, response, error) in
            if data != nil {
                let image = UIImage(data: data!)
                if(image != nil) {
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
}
