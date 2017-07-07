//
//  NavigationToSearch.swift
//  ★★★★★
//
//  Created by Nika on 6/22/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import UIKit

class NavigationToSearch: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let nightBool = nightModeDefaults.value(forKey: nightModeDefaults_Key) as? Bool
        
        if nightBool == false {
            return .lightContent
        } else {
            return .default
        }
    }
}
