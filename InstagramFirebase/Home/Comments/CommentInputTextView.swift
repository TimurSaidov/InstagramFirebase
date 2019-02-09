//
//  CommentInputTextView.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 09/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    fileprivate let placeholder: UILabel = {
        let label = UILabel()
        label.text = "Enter comment"
        label.textColor = UIColor.lightGray
        
        return label
    }()
    
    func showPlaceholder() {
        placeholder.isHidden = false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeholder)
        placeholder.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleTextChange() {
        placeholder.isHidden = !self.text.isEmpty
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
