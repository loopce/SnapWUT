//
//  SendSnapViewController.swift
//  SnapWUT
//
//  Created by Daniel Sandoval on 11/9/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation
import MobileCoreServices
import SwiftForms
import SwiftOverlays

class SendSnapViewController : FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    let cameraController = UIImagePickerController()
    
    var image : UIImage?
    
    var hasPresentedCamera = false
    
    override func viewDidLoad()
    {
        let form = FormDescriptor()
        form.title = "Send a SnapWUT"
        
        let section1 = FormSectionDescriptor()
        section1.headerTitle = "Who to send it to?"
        let userRow = FormRowDescriptor(tag: "username", rowType: .Text, title: "Username")
        section1.addRow(userRow)
        
        let section2 = FormSectionDescriptor()
        section2.headerTitle = "For how long may they see it?"
        let secondsPicker = FormRowDescriptor(tag: "seconds", rowType: .Picker, title: "Time")
        secondsPicker.configuration[FormRowDescriptor.Configuration.Options] = [1, 2, 3, 5, 8, 13]
        secondsPicker.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            switch(value) {
                case 1:
                    return "1 Second"
                case 2:
                    return "2 Seconds"
                case 3:
                    return "3 Seconds"
                case 5:
                    return "5 Seconds"
                case 8:
                    return "8 Seconds"
                case 13:
                    return "13 Seconds"
                default:
                    return nil
            }
            } as TitleFormatterClosure
        secondsPicker.value = 5
        section2.addRow(secondsPicker)
        
        let section3 = FormSectionDescriptor()
        let sendButton = FormRowDescriptor(tag: "send", rowType: .Button, title: "Send")
        sendButton.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
            self.sendSnap()
        }
        section3.addRow(sendButton)
        
        form.sections = [section1, section2, section3]
        
        self.form = form
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        if !self.hasPresentedCamera {
            //Show camera
            self.hasPresentedCamera = true
            self.cameraController.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                self.cameraController.sourceType = .Camera
                self.cameraController.cameraCaptureMode = .Photo
                self.cameraController.cameraFlashMode = .Off
                if UIImagePickerController.isCameraDeviceAvailable(.Front) {
                    self.cameraController.cameraDevice = .Front
                }
            }
            self.cameraController.mediaTypes = [kUTTypeImage as String]
            self.presentViewController(self.cameraController, animated: true, completion: nil)
        } else if self.image == nil {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        self.image = info[UIImagePickerControllerEditedImage] as? UIImage
        if self.image == nil {
            self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendSnap()
    {
        self.view.endEditing(true)
        if self.image == nil {
            self.displayAlert("Error", message: "There is no image to send!", completion: { () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        } else if let toUsername = self.valueForTag("username") as? String,
                    let seconds = self.valueForTag("seconds"),
                    let image = self.image {
            SwiftOverlays.showBlockingWaitOverlay()
            self.getUser(toUsername) { (toUserOptional: PFUser?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "An error occurred while trying to send Snap.", completion: nil)
                    SwiftOverlays.removeAllBlockingOverlays()
                } else if let toUser = toUserOptional {
                    let scaledImg = image.resizeToLargestSize(1000.0)
                    if let imgData = UIImageJPEGRepresentation(scaledImg, 0.8),
                        let imgFile = PFFile(name: "snap.jpg", data: imgData) {
                            imgFile.saveInBackgroundWithBlock() { (saved: Bool, _) -> Void in
                                if (saved) {
                                    let snap = PFObject(className: "Snap")
                                    snap.setObject(toUser, forKey: "destination")
                                    snap.setObject(PFUser.currentUser()!, forKey: "sender")
                                    snap.setObject(imgFile, forKey: "image")
                                    snap.setObject(seconds, forKey: "seconds")
                                    snap.setObject(false, forKey: "seen")
                                    snap.saveInBackgroundWithBlock() { (saved: Bool, _) -> Void in
                                        if (saved) {
                                            SwiftOverlays.removeAllBlockingOverlays()
                                            self.navigationController?.popViewControllerAnimated(true)
                                        } else {
                                            self.displayAlert("Error", message: "Error while sending Snap. Please try again.", completion: nil)
                                            SwiftOverlays.removeAllBlockingOverlays()
                                        }
                                    }
                                } else {
                                    self.displayAlert("Error", message: "Error while sending Snap. Please try again.", completion: nil)
                                    SwiftOverlays.removeAllBlockingOverlays()
                                }
                            }
                    }
                } else {
                    self.displayAlert("Error", message: "This user doesn't exist!", completion: nil)
                    SwiftOverlays.removeAllBlockingOverlays()
                }
            }
        } else {
            self.displayAlert("Error", message: "You must choose an user to send your Snap to!", completion: nil)
        }
    }
    
    func getUser(username : String, completion: ((PFUser?, NSError?) -> Void))
    {
        if let q = PFUser.query() {
            q.whereKey("username", equalTo: username)
            q.getFirstObjectInBackgroundWithBlock() { (result: PFObject?, error: NSError?) -> Void in
                if error?.code == 101 {
                    //No object matches the query.
                    completion(nil, nil)
                } else {
                    completion(result as? PFUser, error)
                }
            }
        }
    }
}