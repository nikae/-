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
import Alamofire
import UserNotifications
import CoreLocation

class SecondVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let databaseRef = FIRDatabase.database().reference()
    let uid = FIRAuth.auth()?.currentUser?.uid
    var users = [User]()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableview.refreshControl = refreshControl
        } else {
            tableview.addSubview(refreshControl)
        }
        
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            self.view.backgroundColor = nightModeColor
            tableview.backgroundColor = nightModeColor
            navigationBar.backgroundColor = nightModeColor
            navigationBar.tintColor = nightModeColor
            navigationBar.barTintColor = nightModeColor
        }
        
        
        
        //MARK: --> Get users from database
        if coordinate1 != nil {
            databaseRef.child("Users").observe(.childAdded , with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let userID = value?["userID"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
                let pictureURL = value?["pictureURL"] as? String ?? ""
                let createdAt = value?["createdAt"] as? String ?? ""
                let rating = value?["rating"] as? Double ?? 5.0
                let ratings = value?["ratings"] as? [String : AnyObject] ?? [:]
                let locations = value?["Location"] as? [String : AnyObject] ?? [:]
                let isActive = value?["isActive"] as? Bool
                
                if locations.count != 0 {
                    if isActive != false {
                        var usersCordinate: CLLocation!
                        let latitude = locations["lat"] as! CLLocationDegrees
                        let longitude = locations["long"] as! CLLocationDegrees
                        usersCordinate = CLLocation(latitude: latitude, longitude: longitude)
                        
                        let distanceInMeters = usersCordinate.distance(from: coordinate1) // result is in meters
                        let distanceInMiles = distanceInMeters * 0.000621371192 //In Miles
                        
                        if userID != self.uid {
                            var rArray = [Rating]()
                            for i in ratings {
                                let creator = i.value["creator"] as! String
                                let createdAt = i.value["createdAt"] as! String
                                let value = i.value["value"] as! Double
                                
                                rArray.append(Rating(creator: creator, createdAt: createdAt, value: value))
                            }
                            
                            if self.users.count < 200 {
                                self.users.append(User(userId: userID, name: name, pictureUrl: pictureURL, createdAt: createdAt, ratings: rArray, rating: rating, distance: distanceInMiles))
                                self.users = self.users.sorted(by: {$0.distance < $1.distance})
                            }
                            self.tableview.reloadData()
                        }
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func refresh(sender:AnyObject) {
        users.removeAll()
        
        if coordinate1 != nil {
            databaseRef.child("Users").observe(.childAdded , with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let userID = value?["userID"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
                let pictureURL = value?["pictureURL"] as? String ?? ""
                let createdAt = value?["createdAt"] as? String ?? ""
                let rating = value?["rating"] as? Double ?? 5.0
                let ratings = value?["ratings"] as? [String : AnyObject] ?? [:]
                let locations = value?["Location"] as? [String : AnyObject] ?? [:]
                let isActive = value?["isActive"] as? Bool
                
                if locations.count != 0 {
                    if isActive != false {
                        var usersCordinate: CLLocation!
                        let latitude = locations["lat"] as! CLLocationDegrees
                        let longitude = locations["long"] as! CLLocationDegrees
                        usersCordinate = CLLocation(latitude: latitude, longitude: longitude)
                        
                        let distanceInMeters = usersCordinate.distance(from: coordinate1) // result is in meters
                        let distanceInMiles = distanceInMeters * 0.000621371192 //In Miles
                        
                        if userID != self.uid {
                            var rArray = [Rating]()
                            for i in ratings {
                                let creator = i.value["creator"] as! String
                                let createdAt = i.value["createdAt"] as! String
                                let value = i.value["value"] as! Double
                                
                                rArray.append(Rating(creator: creator, createdAt: createdAt, value: value))
                            }
                            
                            if self.users.count < 200 {
                                self.users.append(User(userId: userID, name: name, pictureUrl: pictureURL, createdAt: createdAt, ratings: rArray, rating: rating, distance: distanceInMiles))
                                self.users = self.users.sorted(by: {$0.distance < $1.distance})
                            }
                            self.tableview.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            cell.backgroundColor = nightModeColor
            cell.backGroundView.backgroundColor = nightModeColor.withAlphaComponent(0.8)
            cell.imageViewCell!.layer.borderColor = nightModeColor.withAlphaComponent(0.8).cgColor
        } else {
            cell.imageViewCell!.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        }
        
        cell.nameLabelCell.text = users[indexPath.row].name
        cell.starsLabelCell.text = String(format: "%.01f", (users[indexPath.row].rating)!)
        
        if users[indexPath.row].pictureUrl != "" {
            getImage((users[indexPath.row].pictureUrl)!, imageView: cell.imageViewCell)
            getImage((users[indexPath.row].pictureUrl)!, imageView: cell.backgroundImmage)
        } else {
            cell.imageViewCell.image = UIImage(named: "Screen Shot 2017-06-15 at 9.35.49 AM")
            cell.backgroundImmage.image = UIImage(named: "Screen Shot 2017-06-15 at 9.35.49 AM")
        }
        
        cell.backgroundImmage!.layer.cornerRadius = 15
        cell.backgroundImmage!.clipsToBounds = true
        cell.backgroundImmage!.addBlurEffect()
        
        cell.imageViewCell!.clipsToBounds = true
        cell.imageViewCell!.isUserInteractionEnabled = true
        cell.imageViewCell!.layer.cornerRadius = cell.imageViewCell!.frame.height/2
        cell.imageViewCell!.layer.borderWidth = 10
        
        
        cell.backGroundView!.clipsToBounds = true
        cell.backGroundView!.isUserInteractionEnabled = true
        cell.backGroundView!.layer.cornerRadius = 15
        cell.backGroundView!.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        cell.backGroundView!.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cell.backGroundView!.layer.shadowOpacity = 1.0
        cell.backGroundView!.layer.shadowRadius = 5
        cell.backGroundView!.layer.masksToBounds = false
        
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
        
        var isRatedToday: Bool = false
        
        for i in self.users[(indexPath?.row)!].ratings {
            if uid == i.creator {
            let dateFromData = i.createdAt.components(separatedBy: " ").first!
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                let currentDate = formatter.string(from: date)
                if dateFromData == currentDate {
                    isRatedToday = true
                }
            }
        }
        
        if isRatedToday != false {
            let alert = UIAlertController(title: "Already Rated", message: "You already rated \(self.users[(indexPath?.row)!].name!.capitalized) today. Check in tomorrow to rate again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else { 
        
        let alert = UIAlertController(title: "You rated \(self.users[(indexPath?.row)!].name!)", message: "\(star)", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
            if (sender.tag == 201) {
                rateStar(value: 0.2, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else if (sender.tag == 202) {
                rateStar(value: 0.4, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 2)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else if (sender.tag == 203) {
                rateStar(value: 0.6, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 3)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    b3.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else  if (sender.tag == 204) {
                rateStar(value: 0.8, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 4)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    b3.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
                    b4.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else {
                rateStar(value: 1, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 5)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    b3.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
                    b4.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    b5.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                b1.setTitle("☆", for: .normal)
                b2.setTitle("☆", for: .normal)
                b3.setTitle("☆", for: .normal)
                b4.setTitle("☆", for: .normal)
                b5.setTitle("☆", for: .normal)
                AudioServicesPlaySystemSound (sendID)
            })
        }
        
        let okAndShare = UIAlertAction(title: "Confirm and share", style: .default) { (action: UIAlertAction) in
            
            
            if (sender.tag == 201) {
                rateStar(value: 0.2, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 1)
 //MARK: need to update web "https:// .nikaeblog .wordpress .com"
                self.share(message: "I rate \(self.users[(indexPath?.row)!].name!) \(star) out of ★★★★★", link: "\(webLink)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else if (sender.tag == 202) {
                rateStar(value: 0.4, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 2)
                
                self.share(message: "I rate \(self.users[(indexPath?.row)!].name!) \(star) out of ★★★★★", link: "\(webLink)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else if (sender.tag == 203) {
                rateStar(value: 0.6, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 3)
                
                self.share(message: "I rate \(self.users[(indexPath?.row)!].name!) \(star) out of ★★★★★", link: "\(webLink)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    b3.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else  if (sender.tag == 204) {
                rateStar(value: 0.8, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 4)
                
                self.share(message: "I rate \(self.users[(indexPath?.row)!].name!) \(star) out of ★★★★★", link: "\(webLink)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    b3.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
                    b4.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            } else {
                rateStar(value: 1, ratee: (self.users[(indexPath?.row)!].userId)!)
                calcAndUpdateRating(uId: (self.users[(indexPath?.row)!].userId)!)
                self.updateRatingOnCell(atIndex: (indexPath?.row)!, star: 5)
                
                self.share(message: "I rate \(self.users[(indexPath?.row)!].name!) \(star) out of ★★★★★", link: "\(webLink)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    b1.setTitle("☆", for: .normal)
                    b2.setTitle("☆", for: .normal)
                    b3.setTitle("☆", for: .normal)
                    b4.setTitle("☆", for: .normal)
                    b5.setTitle("☆", for: .normal)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    b1.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                    b2.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                    b3.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
                    b4.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    b5.setTitle("★", for: .normal)
                    AudioServicesPlaySystemSound (systemSoundID)
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                b1.setTitle("☆", for: .normal)
                b2.setTitle("☆", for: .normal)
                b3.setTitle("☆", for: .normal)
                b4.setTitle("☆", for: .normal)
                b5.setTitle("☆", for: .normal)
                AudioServicesPlaySystemSound (sendID)
            })
        }

        alert.addAction(okAndShare)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    func share(message: String, link: String) {
        let message = message
        if let link = NSURL(string: link) {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func updateRatingOnCell(atIndex: Int, star: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.databaseRef.child("Users").child((self.users[atIndex].userId)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let rating = value?["rating"] as? Double ?? 0
                let ratings = value?["ratings"] as? [String : AnyObject] ?? [:]
                let token = value?["token"] as? String ?? ""
                var rArray = [Rating]()
                for i in ratings {
                    let creator = i.value["creator"] as! String
                    let createdAt = i.value["createdAt"] as! String
                    let value = i.value["value"] as! Double
                    
                    rArray.append(Rating(creator: creator, createdAt: createdAt, value: value))
                }
                
                self.users[atIndex].ratings = rArray
                self.users[atIndex].rating = rating
                
                
                let ratingStr = String(format: "%.01f", rating)
                
                var headers: HTTPHeaders? = HTTPHeaders()
                let urlstring = "https://fcm.googleapis.com/fcm/send"
                
                headers = [
                    "Content-Type" : "application/json",
                    "Authorization" : "key=AIzaSyC7YP48PanbkiMa4-HNaASvt_47puMMjek"
                ]
                let notification: Parameters? = [
                    "to" : "\(token)",
                    "notification" : [
                        "body" : "You were rated \(star)★. Your current rating is \(String(describing: ratingStr))★.",
                        "title" : "New Rating!",
                        "sound" : "default"
                    ]
                ]
                
                _ = Alamofire.request( urlstring as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers!).responseJSON(completionHandler: { (resp) in print(" resp \(resp)") })
                
                self.tableview.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        })
    }
}
