//
//  Post.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import Foundation

struct Post {
    let user: User
    let imageData: Data?
    let caption: String
    let creationDateNum: Double
    let creationDate: Date
    
    // Если картинки постов грузятся уже после отображения самих постов.
    let imageUrl: String?
}