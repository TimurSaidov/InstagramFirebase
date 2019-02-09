//
//  Post.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import Foundation

struct Post {
    var id: String?
    
    let user: User
    let imageData: Data?
    let caption: String
    let creationDateNum: Double
    let creationDate: Date
    
    var hasLiked: Bool?
    
    // Если картинки постов грузятся уже после отображения самих постов.
    let imageUrl: String?
}
