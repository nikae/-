//
//  RatingMethods.swift
//  ★★★★★
//
//  Created by Nika on 6/6/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import Foundation
import Firebase


//MARK -->> :Pull Down ratings from database, calculate and push final rating back {everitime Someone rates}

func calcAndUpdateRating(uId: String)  {
    //let uId = FIRAuth.auth()?.currentUser?.uid
    let databaseRef = FIRDatabase.database().reference()
    databaseRef.child("Users").child(uId).observeSingleEvent(of: .value, with: { (snapshot) in
        
        let value = snapshot.value as? NSDictionary
        
        let ratings = value?["ratings"] as? [String : AnyObject] ?? [:]
        
        var rArray = [Rating]()
        
        for i in ratings {
            let creator = i.value["creator"] as! String
            let createdAt = i.value["createdAt"] as! String
            let value = i.value["value"] as! Double
            
            rArray.append(Rating(creator: creator, createdAt: createdAt, value: value))
        }
        
        var rDouble: [Double] = []
        
        for i in rArray {
            rDouble.append(i.value)
        }
        
        let result = calcRating(ratings: rDouble)
        let finalRating = (result * 5)
        
        databaseRef.child("Users/\(uId)/rating").setValue(finalRating)
        
    }) { (error) in
        print(error.localizedDescription)
    }
    
    
}


//MARK -->> :Calculate ratings sum
func calcRating( ratings: [Double] ) -> Double {
    var sum: Double = 0
    
    for index in ratings {
        sum += index
    }
    
    let count = ratings.count
    
    return sum / Double(count)
}


func rateStar(value: Double, ratee: String) {
    let databaseRef = FIRDatabase.database().reference()
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy h:mm a"
    let result = formatter.string(from: date)
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    let r = ["creator": userID ?? "", "createdAt": result, "value": value] as [String : Any]
    
    //databaseRef.child("Users/\(ratee)/ratings").child("\(userID!)").setValue(r)
    databaseRef.child("Users/\(ratee)/ratings").childByAutoId().setValue(r)
}
