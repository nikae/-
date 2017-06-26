//
//  TableViewCell.swift
//  ★★★★★
//
//  Created by Nika on 4/3/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var nameLabelCell: UILabel!
    @IBOutlet weak var starsLabelCell: UILabel!
    
    @IBOutlet weak var starStarLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var backgroundImmage: UIImageView!
    
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabelCell.adjustsFontSizeToFitWidth = true
        
        backgroundImmage.addBlurEffect()
        
        backgroundImmage!.layer.cornerRadius = 15
        backgroundImmage!.clipsToBounds = true
        
        imageViewCell!.clipsToBounds = true
        imageViewCell!.isUserInteractionEnabled = true
        imageViewCell!.layer.cornerRadius = imageViewCell!.frame.height/2
        imageViewCell!.layer.borderWidth = 10
        backGroundView!.clipsToBounds = true
        backGroundView!.isUserInteractionEnabled = true
        backGroundView!.layer.cornerRadius = 15
        backGroundView!.layer.masksToBounds = false
                
    }
       
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
