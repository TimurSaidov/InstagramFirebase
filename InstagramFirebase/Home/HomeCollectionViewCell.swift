//
//  HomeCollectionViewCell.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomeCollectionViewCell)
}

class HomeCollectionViewCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    var post: Post?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userProfileLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
    }
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
    }
    
    @objc func handleComment() {
        guard let post = post else { return }
        print("Selected post caption is - \(post.caption)")
        
        delegate?.didTapComment(post: post)
    }
}
