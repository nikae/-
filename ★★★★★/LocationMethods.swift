//
//  LocationMethods.swift
//  ★★★★★
//
//  Created by Nika on 6/12/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AVFoundation

var coordinate1: CLLocation!

var recivedInt: String!

let systemSoundID: SystemSoundID = 1109
let sendID: SystemSoundID = 1055

let borderColor = UIColor(colorLiteralRed: 63/255.0, green: 186/255.0, blue: 235/255.0, alpha: 0.8)

//let nightModeColor = UIColor(colorLiteralRed: 1/255.0, green: 35/255.0, blue: 56/255.0, alpha: 1)
let nightModeColor = UIColor(colorLiteralRed: 38/255.0, green: 50/255.0, blue: 56/255.0, alpha: 1)
let buttonTextColorDark = UIColor(colorLiteralRed: 72/255.0, green: 68/255.0, blue: 75/255.0, alpha: 1)

let webLink = "https://5starsapp.com"

let nightModeDefaults = UserDefaults.standard
let nightModeDefaults_Key = "nightModeDefaults_Key"

func viewShape(view: UIView) {
    view.clipsToBounds = true
    view.layer.cornerRadius = view.frame.height/2
}


func viewShedow(view: UIView) {
    view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
    view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    view.layer.shadowOpacity = 1.0
    view.layer.shadowRadius = 0.0
    view.layer.masksToBounds = false
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
                    
                    UIView.animate(withDuration: 2.5, animations: {
                        imageView.alpha = 1.0
                    })
                    
                })
                
            }
            
        }
        
        
    })
    
    task.resume()
}


//MARK: --> Share method

func share(message: String, link: String) {
//let saveAndShare = UIAlertAction(title: "Save and share", style: .default) { (action: UIAlertAction) in
//    
//    let message = "\( String(format: "%.01f", rating))★ is my rating on ★★★★★"
//    if let link = NSURL(string: "aa")
//    {
//        let objectsToShare = [message,link] as [Any]
//        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
//        self.present(activityVC, animated: true, completion: nil)
//    }
//}
}


