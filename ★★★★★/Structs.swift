//
//  Structs.swift
//  ★★★★★
//
//  Created by Nika on 5/2/17.
//  Copyright © 2017 Nika. All rights reserved.
//

import Foundation

struct Rating {
    let creator : String!
    let createdAt: String!
    let value: Double!
 }

struct User {
    var userId: String!
    var name: String!
    var pictureUrl: String!
    var createdAt: String!
    var ratings: [Rating]!
    var rating: Double!
    var distance: Double!
}

