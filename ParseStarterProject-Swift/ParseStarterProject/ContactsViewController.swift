//
//  ContactsViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
   
    var usernames = [String]()
    var images = [UIImage]()
    var emails = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFUser.query()
        query?.whereKey("accepted", equalTo: (PFUser.currentUser()?.objectId)!)
        query?.whereKey("objectId", containedIn: PFUser.currentUser()?["accepted"] as! [String])
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if let objects = objects {
                
                for object in objects as! [PFUser] {
                    print(object)

                    self.usernames.append(object.username!)
                    self.emails.append(object.email!)
                    let imageFile =  object["image"] as! PFFile
                    
                    imageFile.getDataInBackgroundWithBlock({ (imageData, error) in
                        
                        if error != nil {
                            print(error)
                            
                        } else {
                            if let data = imageData {
                                
                                self.images.append(UIImage(data: data)!)
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usernames.count
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let url = NSURL(string: "mailto:" + emails[indexPath.row])
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = emails[indexPath.row]
        if images.count > indexPath.row {
            cell.imageView?.image = images[indexPath.row]
        }
        return cell
    }
    
    
    


}
