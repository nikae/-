//
//  SearchTVC.swift
//  ★★★★★
//
//  Created by Nika on 6/14/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import Alamofire
import UserNotifications
import CoreLocation

class SearchTVC: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    var searchController: UISearchController!
    
    let databaseRef = FIRDatabase.database().reference()
    let uid = FIRAuth.auth()?.currentUser?.uid
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            
            let bgView = UIView()
            bgView.backgroundColor = nightModeColor
            self.tableView.backgroundView = bgView
            self.view.backgroundColor = nightModeColor
            tableView.backgroundColor = nightModeColor
            navigationController?.navigationBar.barTintColor = nightModeColor
            navigationController?.view.backgroundColor = nightModeColor
        }
        
        self.definesPresentationContext = true
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self    // this controller is delegate
        self.searchController!.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.searchBarStyle = .minimal
        self.tableView.tableHeaderView = self.searchController.searchBar
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.nameLabelCell.text = users[indexPath.row].name
        cell.starsLabelCell.text = String(format: "%.01f", (users[indexPath.row].rating)!)
        
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            //cell.contentView.backgroundColor = nightModeColor
            cell.backgroundColor = nightModeColor
            cell.backGroundView.backgroundColor = nightModeColor.withAlphaComponent(0.8)
            cell.imageViewCell!.layer.borderColor = nightModeColor.withAlphaComponent(0.8).cgColor
        } else {
            cell.imageViewCell!.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        }
        
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
        //cell.imageViewCell!.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        
        cell.backGroundView!.clipsToBounds = true
        cell.backGroundView!.isUserInteractionEnabled = true
        cell.backGroundView!.layer.cornerRadius = 15
        cell.backGroundView!.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        cell.backGroundView!.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cell.backGroundView!.layer.shadowOpacity = 1.0
        cell.backGroundView!.layer.shadowRadius = 5
        cell.backGroundView!.layer.masksToBounds = false
        
        cell.star1.addTarget(self, action: #selector(SearchTVC.buttonClicked), for: .touchUpInside)
        cell.star2.addTarget(self, action: #selector(SearchTVC.buttonClicked), for: .touchUpInside)
        cell.star3.addTarget(self, action: #selector(SearchTVC.buttonClicked), for: .touchUpInside)
        cell.star4.addTarget(self, action: #selector(SearchTVC.buttonClicked), for: .touchUpInside)
        cell.star5.addTarget(self, action: #selector(SearchTVC.buttonClicked), for: .touchUpInside)
        
        return cell
     }
    
    func buttonClicked(sender:UIButton) {
        
        let center = sender.center
        let point = sender.superview!.convert(center, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let cell = tableView.cellForRow(at: indexPath!)
        
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
            let alert = UIAlertController(title: "Alredy Rated", message: "Chack back tommorrow", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else {
        
        let alert = UIAlertController(title: "You rated \(self.users[(indexPath?.row)!].name!)", message: "\(star)", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
            self.searchController.searchBar.isUserInteractionEnabled = false
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
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child("Users").child((self.users[atIndex].userId)!).observeSingleEvent(of: .value, with: { (snapshot) in
                
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
                
                _ = Alamofire.request( urlstring as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers!).responseJSON(completionHandler: { (resp) in
                    print(" resp \(resp)")
                })
                
                self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.searchController.searchBar.isUserInteractionEnabled = true
            })
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        if nightBool == false {
            let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = .gray
            searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        }
        self.users.removeAll()
        filterUsers(userName: searchController.searchBar.text!)
    }
    
    func filterUsers(userName: String) {
        databaseRef.child("Users").observe(.childAdded , with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let userID = value?["userID"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            let pictureURL = value?["pictureURL"] as? String ?? ""
            let createdAt = value?["createdAt"] as? String ?? ""
            let rating = value?["rating"] as? Double ?? 5.0
            let ratings = value?["ratings"] as? [String : AnyObject] ?? [:]
            let isActive = value?["isActive"] as? Bool

            
            if userID != self.uid {
                if isActive != false {
                var rArray = [Rating]()
                for i in ratings {
                    let creator = i.value["creator"] as! String
                    let createdAt = i.value["createdAt"] as! String
                    let value = i.value["value"] as! Double
                    
                    rArray.append(Rating(creator: creator, createdAt: createdAt, value: value))
                }
                
                if name.lowercased().contains(userName.lowercased()) && name != "" {
                    self.users.append(User(userId: userID, name: name, pictureUrl: pictureURL, createdAt:createdAt, ratings: rArray, rating: rating, distance: 0))
                    
                    self.tableView.reloadData()
                } else {
                    self.tableView.reloadData()
                }
            }
        }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func dissmissHit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
