//
//  LoginViewController.swift
//  SnapWUT
//
//  Created by Daniel Sandoval on 10/31/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("loginWithoutAnimation", sender: nil)
        }
    }

    @IBAction func pressLoginWithFacebook(sender: UIButton) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["email", "user_about_me", "public_profile", "user_friends"])
            { (userOptional : PFUser?, error : NSError?) -> Void in
                if let user = userOptional {
                    let installation = PFInstallation.currentInstallation()
                    installation.setObject(user, forKey: "user")
                    installation.saveInBackground()
                    self.performSegueWithIdentifier("login", sender: nil)
                } else if let e = error {
                    NSLog("Error: %@", e)
                } else {
                    NSLog("We don't have an user and we don't have an error.")
                }
        }
    }

}

