//
//  PostCell.swift
//  Social
//
//  Created by Umer Khan on 4/7/17.
//  Copyright © 2017 Umer Khan. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    @IBOutlet weak var Profile: UIImageView!
    @IBOutlet weak var Post: UIImageView!
    @IBOutlet weak var Like: UIImageView!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var Likes: UILabel!
    @IBOutlet weak var Caption: UITextView!
    @IBOutlet weak var likeLabel: UILabel!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        self.Caption.text = post.caption
        self.Likes.text = "\(post.likes)" //int as a string
        
        if img != nil{
            self.Post.image = img
        } else {
                let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil{
                        print("Umer: Unable to download image from Firebase storage")
                    } else{
                        print("Umer: Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.Post.image = img
                                FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                            }
                        }
                    }
                    
                })
        }
     }
}
