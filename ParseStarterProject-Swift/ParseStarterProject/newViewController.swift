//
//  newViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/13/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class newViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        //PFUser.logOut()
//        let push = PFPush()
//        push.setChannel("Giants")
//        push.setMessage("Giants just scored")
//        push.sendPushInBackground()
        

}
    override func viewDidAppear(animated: Bool) {
        
        if (PFUser.currentUser()?.objectId) != nil {
            
            if (PFUser.currentUser()?["interestedInWomen"]) != nil {
                
                performSegueWithIdentifier("logUserIn", sender: self)
                
            } else {
            
                performSegueWithIdentifier("fbSignUp", sender: self)
            }
        }
    }

    @IBAction func load(sender: AnyObject) {
        
        loadFB()
    }
    
    
    func loadFB() {
        
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user:PFUser?, error:NSError?) -> Void in
            
            if let error = error {
                
                print(error)
                print("ohho")
                
            } else {
                
                if let user = user {
                    
                    if user["interestedInWomen"] != nil {
                        
                        self.performSegueWithIdentifier("logUserIn", sender: self)
                        
                    } else {
                        
                        self.performSegueWithIdentifier("fbSignUp", sender: self)
                        
                    }

                }
            }

        }
    }
    
}
