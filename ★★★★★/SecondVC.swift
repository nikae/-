//
//  SecondVC.swift
//  ★★★★★
//
//  Created by Nika on 4/3/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation



class SecondVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
  
        @IBOutlet weak var tableview: UITableView!
    
    let databaseRef = FIRDatabase.database().reference()
    let uid = FIRAuth.auth()?.currentUser?.uid
    var users = [User]()
    
    let systemSoundID: SystemSoundID = 1109
    let sendID: SystemSoundID = 1055
    let borderColor = UIColor(colorLiteralRed: 63/255.0, green: 186/255.0, blue: 235/255.0, alpha: 0.8)
    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            databaseRef.child("Users").observe(.childAdded , with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let userID = value?["userID"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
                let pictureURL = value?["pictureURL"] as? String ?? ""
                let createdAt = value?["createdAt"] as? String ?? ""
                let rating = value?["rating"] as? Double ?? 5.0
                let ratings = value?["ratings"] as? [String : AnyObject] ?? [:]
              
                var rArray = [Rating]()
                
                for i in ratings {
                    let creator = i.value["creator"] as! String
                    let createdAt = i.value["createdAt"] as! String
                    let value = i.value["value"] as! Double
                    
                    rArray.append(Rating(creator: creator, createdAt: createdAt, value: value))
                }
                
                self.users.append(User(userId: userID, name: name, pictureUrl: pictureURL, createdAt: createdAt, ratings: rArray, rating: rating))
                self.tableview.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.nameLabelCell.text = users[indexPath.row].name
        cell.starsLabelCell.text = String(format: "%.01f", users[indexPath.row].rating)
        
        if users[indexPath.row].pictureUrl != "" {
            getImage(users[indexPath.row].pictureUrl, imageView: cell.imageViewCell)
            getImage(users[indexPath.row].pictureUrl, imageView: cell.backgroundImmage)
        } else {
            cell.imageViewCell.image = UIImage(named: "IMG_7101")
            cell.backgroundImmage.image = UIImage(named: "IMG_7101")
        }
        
        cell.backgroundImmage!.layer.cornerRadius = 15
        cell.backgroundImmage!.clipsToBounds = true
        cell.imageViewCell!.clipsToBounds = true
        cell.imageViewCell!.isUserInteractionEnabled = true
        cell.imageViewCell!.layer.cornerRadius = cell.imageViewCell!.frame.height/2
        cell.imageViewCell!.layer.borderWidth = 10
        cell.imageViewCell!.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        
        cell.backGroundView!.clipsToBounds = true
        cell.backGroundView!.isUserInteractionEnabled = true
        cell.backGroundView!.layer.cornerRadius = 15
        cell.backGroundView!.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        cell.backGroundView!.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cell.backGroundView!.layer.shadowOpacity = 1.0
        cell.backGroundView!.layer.shadowRadius = 5
        cell.backGroundView!.layer.masksToBounds = false
        
        
//        let r = users[indexPath.row].ratings
//        
//        for i in r! {
//            if i.creator! == uid {
//                if i.value! == 0.2 {
//                    cell.star1.setTitle("★", for: .normal)
//                } else if i.value! == 0.4 {
//                    cell.star1.setTitle("★", for: .normal)
//                    cell.star2.setTitle("★", for: .normal)
//                } else if i.value! == 0.6 {
//                    cell.star1.setTitle("★", for: .normal)
//                    cell.star2.setTitle("★", for: .normal)
//                    cell.star3.setTitle("★", for: .normal)
//                } else if i.value! == 0.8 {
//                    cell.star1.setTitle("★", for: .normal)
//                    cell.star2.setTitle("★", for: .normal)
//                    cell.star3.setTitle("★", for: .normal)
//                    cell.star4.setTitle("★", for: .normal)
//                } else if i.value! == 1 {
//                    cell.star1.setTitle("★", for: .normal)
//                    cell.star2.setTitle("★", for: .normal)
//                    cell.star3.setTitle("★", for: .normal)
//                    cell.star4.setTitle("★", for: .normal)
//                    cell.star5.setTitle("★", for: .normal)
//                }
//            }
//        }
        
        cell.star1.addTarget(self, action: #selector(SecondVC.buttonClicked), for: .touchUpInside)
        cell.star2.addTarget(self, action: #selector(SecondVC.buttonClicked), for: .touchUpInside)
        cell.star3.addTarget(self, action: #selector(SecondVC.buttonClicked), for: .touchUpInside)
        cell.star4.addTarget(self, action: #selector(SecondVC.buttonClicked), for: .touchUpInside)
        cell.star5.addTarget(self, action: #selector(SecondVC.buttonClicked), for: .touchUpInside)
        
        return cell
    }
    
    
    func buttonClicked(sender:UIButton) {
        
        let center = sender.center
        let point = sender.superview!.convert(center, to: tableview)
        let indexPath = tableview.indexPathForRow(at: point)
        
        let cell = tableview.cellForRow(at: indexPath!)
        
        let b1 = cell?.viewWithTag(201) as! UIButton
        let b2 = cell?.viewWithTag(202) as! UIButton
        let b3 = cell?.viewWithTag(203) as! UIButton
        let b4 = cell?.viewWithTag(204) as! UIButton
        let b5 = cell?.viewWithTag(205) as! UIButton
        
        var star = ""
        if (sender.tag == 201) { star = "★" }
        else if (sender.tag == 202) { star = "★★" }
        else if (sender.tag == 203) { star = "★★★" }
        else if (sender.tag == 204) { star = "★★★★" }
        else if (sender.tag == 205) { star = "★★★★★" }
        
  
        let alert = UIAlertController(title: "\(self.users[(indexPath?.row)!].name!)", message: "\(star)", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) in
                    
                    if (sender.tag == 201) {
                        rateStar(value: 0.2, ratee: self.users[(indexPath?.row)!].userId)
                        calcAndUpdateRating(uId: self.users[(indexPath?.row)!].userId)
                        self.updateRatingOnCell(atIndex: (indexPath?.row)!)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                            b1.setTitle("☆", for: .normal)
                            b2.setTitle("☆", for: .normal)
                            b3.setTitle("☆", for: .normal)
                            b4.setTitle("☆", for: .normal)
                            b5.setTitle("☆", for: .normal)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                            b1.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                    } else if (sender.tag == 202) {
                        rateStar(value: 0.4, ratee: self.users[(indexPath?.row)!].userId)
                        calcAndUpdateRating(uId: self.users[(indexPath?.row)!].userId)
                        self.updateRatingOnCell(atIndex: (indexPath?.row)!)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                            b1.setTitle("☆", for: .normal)
                            b2.setTitle("☆", for: .normal)
                            b3.setTitle("☆", for: .normal)
                            b4.setTitle("☆", for: .normal)
                            b5.setTitle("☆", for: .normal)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                            b1.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                            b2.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                    } else if (sender.tag == 203) {
                        rateStar(value: 0.6, ratee: self.users[(indexPath?.row)!].userId)
                        calcAndUpdateRating(uId: self.users[(indexPath?.row)!].userId)
                        self.updateRatingOnCell(atIndex: (indexPath?.row)!)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                            b1.setTitle("☆", for: .normal)
                            b2.setTitle("☆", for: .normal)
                            b3.setTitle("☆", for: .normal)
                            b4.setTitle("☆", for: .normal)
                            b5.setTitle("☆", for: .normal)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                            b1.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                            b2.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                            b3.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                    } else  if (sender.tag == 204) {
                        rateStar(value: 0.8, ratee: self.users[(indexPath?.row)!].userId)
                        calcAndUpdateRating(uId: self.users[(indexPath?.row)!].userId)
                        self.updateRatingOnCell(atIndex: (indexPath?.row)!)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                            b1.setTitle("☆", for: .normal)
                            b2.setTitle("☆", for: .normal)
                            b3.setTitle("☆", for: .normal)
                            b4.setTitle("☆", for: .normal)
                            b5.setTitle("☆", for: .normal)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                            b1.setTitle("★", for: .normal)
                            
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                            b2.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                            b3.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
                            b4.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                    } else {
                        rateStar(value: 1, ratee: self.users[(indexPath?.row)!].userId)
                        calcAndUpdateRating(uId: self.users[(indexPath?.row)!].userId)
                        self.updateRatingOnCell(atIndex: (indexPath?.row)!)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                            b1.setTitle("☆", for: .normal)
                            b2.setTitle("☆", for: .normal)
                            b3.setTitle("☆", for: .normal)
                            b4.setTitle("☆", for: .normal)
                            b5.setTitle("☆", for: .normal)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                            b1.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                            b2.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                            b3.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
                            b4.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            b5.setTitle("★", for: .normal)
                            AudioServicesPlaySystemSound (self.systemSoundID)
                        })
                    }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                b1.setTitle("☆", for: .normal)
                b2.setTitle("☆", for: .normal)
                b3.setTitle("☆", for: .normal)
                b4.setTitle("☆", for: .normal)
                b5.setTitle("☆", for: .normal)
                AudioServicesPlaySystemSound (self.sendID)
            })
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
//    func checkForDate(str: String) -> Bool {
//        
//        
//        let uid = FIRAuth.auth()?.currentUser?.uid
//        let databaseRef = FIRDatabase.database().reference()
//        
//        databaseRef.child("Users/\(str)/ratings").observe(.childAdded , with: { (snapshot) in
//            
//            let value = snapshot.value as? NSDictionary
//            let creator = value!["creator"] as! String
//            
//            if creator != uid {
//               return true
//                
//            }
//        })
//        
//        return false
//    }
    
    func updateRatingOnCell(atIndex: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child("Users").child(self.users[atIndex].userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                let rating = value?["rating"] as? Double
                
                self.users[atIndex].rating = rating
                
                
                self.tableview.reloadData()
                
            }) { (error) in
                print(error.localizedDescription)
            }
        })

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
                        imageView.alpha = 1
                        
                        UIView.animate(withDuration: 1, animations: {
                            imageView.alpha = 1.0
                        })
                        
                    })
                    
                }
                
            }
            
            
        })
        
        task.resume()
    }
}
