//
//  FeedVC.swift
//  Social
//
//  Created by Umer Khan on 4/7/17.
//  Copyright © 2017 Umer Khan. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var imageAdd: UIImageView!
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    
    
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedVC.dismissKeyboard))
    
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    
    }
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell{
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString){
                cell.configureCell(post: post, img: img)
                return cell
            } else{
                cell.configureCell(post: post)
                return cell
            }
            
          
        } else{
            return PostCell()
        }
       
        
        
        /*let post = posts[indexPath.row]
        print("Umer: \(post.caption)")
 */
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            imageAdd.image = image
            imageSelected = true
        } else{
            print("Umer: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else{
            print(" UMER: Caption must be entered")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else{
            print( " Umer: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg" //tell firebase it's a JPEG
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil{
                    print("UMER: Unable to upload image to Firebase storage")
                    
                }else{
                    print("UMER: Successfully uploaded image to Firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(imgUrl: url)
                    }
                   
                }
                
                
                
            }
            
        }
    }
    
    func postToFirebase(imgUrl: String){
        let post: Dictionary<String, AnyObject> = [
    
            "caption": captionField.text! as AnyObject, "imageUrl": imgUrl as AnyObject, "likes": 0 as AnyObject
        ]
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }
    
    
    @IBAction func signOutPrssed(_ sender: Any) {
    
    
    let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)//removeObjectForKey
    print("Umer: ID removed from keychain \(keychainResult)")
    try! FIRAuth.auth()?.signOut()
    performSegue(withIdentifier: "Login", sender: nil)
}
 






}
