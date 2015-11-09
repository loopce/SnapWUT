//
//  MainViewController.swift
//  SnapWUT
//
//  Created by Daniel Sandoval on 11/1/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation

class MainViewController: UITableViewController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let user = PFUser.currentUser() {
            if (user.isNew) {
                self.performSegueWithIdentifier("registrationNoAnimation", sender: nil)
            }
        }
    }
    
}