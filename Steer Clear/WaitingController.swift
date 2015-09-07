//
//  WaitingController.swift
//  Steer Clear
//
//  Created by Rodolfo Giacoman on 8/4/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import QuartzCore

class WaitingController: UIViewController {

    @IBOutlet var etaLabel: UILabel!
    var currentRide: Ride!
    let defaults = NSUserDefaults.standardUserDefaults()
    var fullETA = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        setupETA()

    }

    func setupETA() {
        
        self.etaLabel.layer.masksToBounds = true;
        self.etaLabel.layer.cornerRadius = 0.5 * self.etaLabel.bounds.size.width
        
        if (self.defaults.objectForKey("pickupTime") != nil) {
            fullETA = self.defaults.objectForKey("pickupTime") as! String
            print(fullETA)
        }

//        if currentRide.pickupTime != fullETA{
//            fullETA = toString(currentRide.pickupTime)
//        }
//        
        
        
//        if (defaults.stringForKey("pickupTime") != nil) {
//                fullETA = toString(defaults.stringForKey("pickupTime"))
//        }
        
        if fullETA != "" {

            
            let dateAsString = "\(fullETA)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
            let date = dateFormatter.dateFromString(dateAsString)
            
            dateFormatter.dateFormat = "h:mm"
            let date24 = dateFormatter.stringFromDate(date!)
            etaLabel.text = "\(date24)"
        } else {
            println("For some reason eta not given.")
        }

        
    }
    
    @IBAction func cancelRideButton(sender: AnyObject) {
        var currentRideId = defaults.stringForKey("rideID")
        
        SCNetwork.deleteRideWithId(currentRideId!,
            completionHandler: {
                success, message in
                
                // can't make UI updates from background thread, so we need to dispatch
                // them to the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // check if registration succeeds
                    if(!success) {
                        // if it failed, display error
                        self.displayAlert("Ride Error", message: message)
                    } else {
                        self.defaults.setObject(nil, forKey: "pickupTime")
                        self.defaults.setObject(nil, forKey: "rideID")
                        self.performSegueWithIdentifier("cancelRideSegue", sender: self)
                    }
                })
        })
        
        
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
