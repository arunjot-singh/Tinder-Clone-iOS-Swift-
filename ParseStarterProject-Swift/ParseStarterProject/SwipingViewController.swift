//
//  SwipingViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SwipingViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var dislayedUserId = ""
    

    override func viewDidLoad() {
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(SwipingViewController.wasDragged(_:)))
        userImage.addGestureRecognizer(gesture)
        
        userImage.userInteractionEnabled = true
        
//        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) in
//            
//            if let geoPoint = geoPoint {
//                
//                PFUser.currentUser()?["location"] = geoPoint
//                PFUser.currentUser()?.saveInBackground()
//            }
//        }
        
        updateToNewUser()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logOut" {
            
            PFUser.logOut()
        }
    }
    
    func updateToNewUser() {
        
        let query = PFUser.query()
        
        if let latitude = PFUser.currentUser()?["location"]!.latitude {
            
            if let longitude = PFUser.currentUser()?["location"]!.longitude {
                
                query?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))

            }
        }
        
        var interestedIn = "male"
        if (PFUser.currentUser()?["interestedInWomen"])! as! Bool == true {
            interestedIn = "female"
        }
        
        var isFemale = true
        if (PFUser.currentUser()?["gender"])! as! String == "male" {
            isFemale = false
        }
        
        query?.whereKey("gender", equalTo: interestedIn)
        query?.whereKey("interestedInWomen", equalTo: isFemale)
        
        var ignoredUsers = [AnyObject]()
        if let acceptedUsers = PFUser.currentUser()?["accepted"] {
            ignoredUsers += acceptedUsers as! Array
        }
        if let rejectedUsers = PFUser.currentUser()?["rejected"] {
            ignoredUsers += rejectedUsers as! Array
        }

        query?.whereKey("objectId", notContainedIn: ignoredUsers)

        query?.limit = 1
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if error != nil {
                print(error)
            } else if let objects = objects {
                
                print(objects)

                
                for object in objects {
                    self.dislayedUserId = object.objectId!
                    let imageFile = object["image"] as! PFFile
                    imageFile.getDataInBackgroundWithBlock({ (imageData, error) in
                        
                        if error != nil {
                            print(error)
                        } else {
                            if let data = imageData {
                                
                                self.userImage.image = UIImage(data: data)
                            }
                        }
                    })
                    
                }
            }
        })

    }
    
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        let imageView = gesture.view!
        
        imageView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = imageView.center.x - self.view.bounds.width / 2
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        imageView.transform = stretch
        
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var acceptedORrejected = ""
            
            if imageView.center.x < 100 {
                
                acceptedORrejected = "rejected"
            } else if imageView.center.x > self.view.bounds.width - 100 {
                
                acceptedORrejected = "accepted"
                
            }
            
            if acceptedORrejected != "" {
                PFUser.currentUser()?.addUniqueObjectsFromArray([dislayedUserId], forKey: acceptedORrejected)
                PFUser.currentUser()?.saveInBackground()

            }
            
            rotation = CGAffineTransformMakeRotation(0)
            
            stretch = CGAffineTransformScale(rotation, 1, 1)
            
            imageView.transform = stretch
            
            imageView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
            updateToNewUser()
            
        }
    }

}
