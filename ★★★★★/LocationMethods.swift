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



let p = "5-stars Privacy Policy Information Collection Information UsageInformation Protection Cookie Usage 3rd Party Disclosure 3rd Party Links Google AdSense COPPA Our Contact Information This privacy policy has been compiled to better serve those who are concerned with how their 'Personally Identifiable Information' (PII) is being used online. PII, as described in US privacy law and information security, is information that can be used on its own or with other information to identify, contact, or locate a single person, or to identify an individual in context. Please read our privacy policy carefully to get a clear understanding of how we collect, use, protect or otherwise handle your Personally Identifiable Information in accordance with our website. What personal information do we collect from the people that visit our blog, website or app? When ordering or registering on our site, as appropriate, you may be asked to enter your name, email address, Profile picture or other details to help you with your experience. When do we collect information? We collect information from you when you register on our site or enter information on our site. How do we use your information? We may use the information we collect from you when you register, make a purchase, sign up for our newsletter, respond to a survey or marketing communication, surf the website, or use certain other site features in the following ways:• To personalize your experience and to allow us to deliver the type of content and product offerings in which you are most interested. • To improve our website in order to better serve you. How do we protect your information? We do not use vulnerability scanning and/or scanning to PCI standards. We only provide articles and information. We never ask for credit card numbers. We do not use Malware Scanning. We do not use an SSL certificate• We do not need an SSL because:We dont ask for credit card information Do we use 'cookies'? We do not use cookies for tracking purposesYou can choose to have your computer warn you each time a cookie is being sent, or you can choose to turn off all cookies. You do this through your browser settings. Since browser is a little different, look at your browser's Help Menu to learn the correct way to modify your cookies. If you turn cookies off, Some of the features that make your site experience more efficient may not function properly.that make your site experience more efficient and may not function properly. Third-party disclosure We do not sell, trade, or otherwise transfer to outside parties your Personally Identifiable Information.Third-party links Occasionally, at our discretion, we may include or offer third-party products or services on our website. These third-party sites have separate and independent privacy policies. We therefore have no responsibility or liability for the content and activities of these linked sites. Nonetheless, we seek to protect the integrity of our site and welcome any feedback about these sites. Google Google's advertising requirements can be summed up by Google's Advertising Principles. They are put in place to provide a positive experience for users. https://support.google.com/adwordspolicy/answer/1316548?hl=en We have not enabled Google AdSense on our site but we may do so in the future. COPPA (Children Online Privacy Protection Act) When it comes to the collection of personal information from children under the age of 13 years old, the Children's Online Privacy Protection Act (COPPA) puts parents in control. The Federal Trade Commission, United States' consumer protection agency, enforces the COPPA Rule, which spells out what operators of websites and online services must do to protect children's privacy and safety online. We do not specifically market to children under the age of 13 years old. Do we let third-parties, including ad networks or plug-ins collect PII from children under 13?CAN SPAM Act The CAN-SPAM Act is a law that sets the rules for commercial email, establishes requirements for commercial messages, gives recipients the right to have emails stopped from being sent to them, and spells out tough penalties for violations. We collect your email address in order to: To be in accordance with CANSPAM, we agree to the following: If at any time you would like to unsubscribe from receiving future emails, you can email us at and we will promptly remove you from ALL correspondence. Contacting Us If there are any questions regarding this privacy policy, you may contact us using the information below.Last Edited on 2017-06-29"


