//
//  Util.swift
//  SnapWUT
//
//  Created by Daniel Sandoval on 11/1/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation

extension UIViewController
{
    func displayError(error: NSError)
    {
        self.displayError(error, completion: nil)
    }
    
    func displayError(error: NSError, completion: (() -> Void)?)
    {
        self.displayAlert("Error", message: error.localizedDescription, completion: completion)
    }
    
    func displayAlert(title : String, message : String, completion: (() -> Void)?)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default)
            { (_ : UIAlertAction) in
            if let compl = completion {
                compl()
            }
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension UIImage
{
    func resizeToLargestSize(size: CGFloat) -> UIImage
    {
        let factor = (self.size.height > self.size.width) ? (size / self.size.height) : (size / self.size.width)
        let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(factor, factor))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

class SnapCell : PFTableViewCell
{
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func setDate(date: NSDate?)
    {
        if let dt = date {
            let formatter = NSDateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("EEEE',' dd/MM/yyyy hh:mm a")
            dateLabel.text = formatter.stringFromDate(dt)
        }
    }
    
    func setReceived()
    {
        iconView.image = UIImage(named: "arrow_down")
    }
    
    func setSent()
    {
        iconView.image = UIImage(named: "arrow_up")
    }

}