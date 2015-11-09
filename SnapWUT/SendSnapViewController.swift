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
        let sendButton = FormRowDescriptor(tag: "send0", rowType: .Button, title: "Send")
        section2.addRow(sendButton)
        
        form.sections = [section1, section2]
        
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
        } else if let image = self.image {
            //Do image code here?
        } else {
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
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}