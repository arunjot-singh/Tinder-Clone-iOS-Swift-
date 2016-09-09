//
//  SignUpViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class SignUpViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var interestedInWomen: UISwitch!
    
    @IBAction func signUp(sender: AnyObject) {
        
        PFUser.currentUser()?["interestedInWomen"] = interestedInWomen.on
       PFUser.currentUser()?.saveInBackground()
        performSegueWithIdentifier("signedUp", sender: self)
    }
    
    override func viewDidLoad() {
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender, email"])
        graphRequest.startWithCompletionHandler { (connection, result, error) in
            
            if error != nil {
                print(error)
            } else if let result = result {
                
                print(result)
                PFUser.currentUser()?["gender"] = result["gender"]!
                PFUser.currentUser()?["name"] = result["name"]!
                PFUser.currentUser()?["email"] = result["email"]!

                PFUser.currentUser()?.saveInBackground()
                
                let userID = result["id"]! as! String
                let fbProfilePictureURL = "http://graph.facebook.com/" + userID + "/picture?type=large"
                
                if let fbPicURL = NSURL(string: fbProfilePictureURL) {
                    
                    if let data = NSData(contentsOfURL: fbPicURL) {
                        
                        self.userImage.image = UIImage(data: data)
                        
                        let imageFile = PFFile(data: data)
                        PFUser.currentUser()?["image"] = imageFile
                        PFUser.currentUser()?.saveInBackground()
                        
                    }
                    PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) in
                        
                        if let geoPoint = geoPoint {
                            
                            PFUser.currentUser()?["location"] = geoPoint
                        }
                        PFUser.currentUser()?.saveInBackground()

                    }
                    
                }
            }
        }
    }
}
