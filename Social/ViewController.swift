//
//  ViewController.swift
//  Social
//
//  Created by Umer Khan on 4/5/17.
//  Copyright © 2017 Umer Khan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var txtEmail: FancyField! 
    @IBOutlet weak var txtPassword: FancyField!
    /*
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){ //use instead of .stringForKey
            print("Umer: ID found in keychain")
                   performSegue(withIdentifier: "TestVC", sender: nil)
        }
    }
   */
    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Umer: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Umer: User cancelled Facebook authentication")
            } else {
                print("Umer: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }

    }
    
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        if let email = txtEmail.text, let password = txtPassword.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("Umer: User authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Umer: Unable to authenticate with Firebase using email")
                        } else {
                            print("Umer: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }  

    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Umer: Unable to authenticate with Firebase - \(error)")
            } else {
                print("Umer: Successfully authenticated with Firebase")
                if let user = user{
                    let userData = ["provider" : credential.provider]
                 self.completeSignIn(id: user.uid, userData: userData) //.setString
                    
                }
                /*if let user = user {
                   let userData = ["provider" : credential.provider]
                    self.completeSignIn(uid: user.uid, userData: userData)
                }
            }
 
        })
 */
        }
    })
    }
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID) //.setString
        print("umer: Data saved to keychain \(keychainResult)")
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        
  /*
    private func completeSignIn(uid: String, userData: [String : String]) {
        let keychainResult = KeychainWrapper(serviceName: "uid", accessGroup: KEY_UID)
        print("umer: Data saved to keychain \(keychainResult)")
 */
        /*
 DataService.ds.createFBDBUser(uid, userData: userData)
        _ = KeychainWrapper.defaultKeychainWrapper().setString("uid", forKey: KEY_UID)
 */
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){// stringForKey(Key_UID) {
            print("Umer: ID found in Keychain")
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
               /* if let _ = KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID) {
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
    */
    
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

