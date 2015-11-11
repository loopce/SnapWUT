//
//  MainViewController.swift
//  SnapWUT
//
//  Created by Daniel Sandoval on 11/1/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation

class MainViewController: PFQueryTableViewController {
    
    var imageToDisplay : UIImage?
    
    var snapToDisplay : PFObject?
    
    var loadedSnaps = [String : UIImage]()
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        self.loadObjects()
    }
    
    override func viewDidLoad()
    {
        self.parseClassName = "Snap"
        self.pullToRefreshEnabled = true
        super.viewDidLoad()
        if let user = PFUser.currentUser() {
            if (user.isNew) {
                self.performSegueWithIdentifier("registrationNoAnimation", sender: nil)
            }
        }
    }
    
    override func queryForTable() -> PFQuery
    {
        let queryFrom = PFQuery(className: "Snap")
        queryFrom.whereKey("sender", equalTo: PFUser.currentUser()!)
        let queryTo = PFQuery(className: "Snap")
        queryTo.whereKey("destination", equalTo: PFUser.currentUser()!)
        let query = PFQuery.orQueryWithSubqueries([queryFrom, queryTo])
        query.orderByDescending("createdAt")
        query.includeKey("sender")
        query.includeKey("destination")
        return query
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath,
        object: PFObject?) -> PFTableViewCell?
    {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("snapCell") as? SnapCell {
                if let snap = object,
                    let sender = snap.objectForKey("sender") as? PFUser,
                    let destination = snap.objectForKey("destination") as? PFUser {
                        if sender.objectId == PFUser.currentUser()?.objectId {
                            cell.setSent()
                            cell.label.text = destination.username
                        } else {
                            cell.setReceived()
                            cell.label.text = sender.username
                        }
                        cell.setDate(snap.createdAt)
                        updateCellMessage(cell, snap: snap)
                }
                return cell
            }
            
            return nil;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 71.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let snap = self.objectAtIndexPath(indexPath),
            let seen = snap.objectForKey("seen") as? Bool {
                if userIsSenderOfSnap(snap) || !seen,
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as? SnapCell {
                    if hasLoadedImageFor(snap) {
                        showSnap(snap)
                        updateCellMessage(cell, snap: snap)
                    } else {
                        loadSnap(snap, updateCell: cell)
                    }
                }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func updateCellMessage(cell: SnapCell, snap: PFObject)
    {
        if let seen = snap.objectForKey("seen") as? Bool {
            if userIsSenderOfSnap(snap) || !seen {
                if hasLoadedImageFor(snap) {
                    cell.messageLabel.text = "Tap to see..."
                } else {
                    cell.messageLabel.text = "Tap to load..."
                }
            } else {
                cell.messageLabel.text = "Already seen"
            }
        }
    }
    
    func loadSnap(snap: PFObject, updateCell cell: SnapCell)
    {
        if let imgFile = snap.objectForKey("image") as? PFFile {
            imgFile.getDataInBackgroundWithBlock({ (imgData: NSData?, error: NSError?) -> Void in
                if let data = imgData {
                    self.loadedSnaps[snap.objectId!] = UIImage(data: data)
                    self.updateCellMessage(cell, snap: snap)
                }
            })
        }
    }
    
    func showSnap(snap: PFObject)
    {
        if let image = loadedSnaps[snap.objectId!] {
            self.imageToDisplay = image
            self.snapToDisplay = snap
            self.performSegueWithIdentifier("displayImage", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "displayImage",
            let image = self.imageToDisplay,
            let displayController = segue.destinationViewController as? DisplayImageViewController {
                displayController.image = image
                if let secs = snapToDisplay?.objectForKey("seconds") as? Int {
                    displayController.seconds = secs
                }
                snapToDisplay?.setObject(true, forKey: "seen")
                snapToDisplay?.saveInBackground()
        }
    }
    
    func hasLoadedImageFor(snap: PFObject) -> Bool
    {
        return loadedSnaps.indexForKey(snap.objectId!) != nil
    }
    
    func userIsSenderOfSnap(snap: PFObject) -> Bool
    {
        if let sender = snap.objectForKey("sender") as? PFUser {
            return (sender.objectId == PFUser.currentUser()?.objectId)
        }
        return false
    }
    
}