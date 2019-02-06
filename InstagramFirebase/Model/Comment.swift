//
//  Comment.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 06/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import Foundation

struct Comment {
    let text: String
    let uid: String
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
