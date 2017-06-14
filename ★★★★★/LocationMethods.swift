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

let systemSoundID: SystemSoundID = 1109
let sendID: SystemSoundID = 1055

let borderColor = UIColor(colorLiteralRed: 63/255.0, green: 186/255.0, blue: 235/255.0, alpha: 0.8)

func viewShape(view: UIView) {
    //but.backgroundColor = color
    view.clipsToBounds = true
    view.layer.cornerRadius = view.frame.height/2
    // but.layer.shadowRadius
}


func viewShedow(view: UIView) {
    view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
    view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    view.layer.shadowOpacity = 1.0
    view.layer.shadowRadius = 0.0
    view.layer.masksToBounds = false
    // but.layer.cornerRadius = 4.0
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

