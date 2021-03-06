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

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var etaLabel: UILabel!
    var currentRide: Ride!
    let defaults = NSUserDefaults.standardUserDefaults()
    var fullETA = ""
    var settings = Settings()
    var navWidth = CGFloat()
    
    @IBOutlet weak var overlay: UIView!
    var isRotating = false
    var shouldStopRotating = false
    
    @IBOutlet weak var gear: UIImageView!
    
    
    override func viewDidLayoutSubviews() {
        self.navWidth = self.navigationBar.frame.width
        let navBorder = CALayer()
        navBorder.backgroundColor = settings.spiritGold.CGColor
        navBorder.frame = CGRect(x: 0, y: 44, width: self.navWidth, height: 5)
        navigationBar.layer.addSublayer(navBorder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let name = "WaitingController"
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        self.gear.alpha = 0.0
        self.overlay.alpha = 0.0
        etaLabel.hidden = true
        dropTime()
    }

    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationWillEnterForegroundNotification, object: nil);
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let navBorder = CALayer()
        navBorder.backgroundColor = settings.spiritGold.CGColor
        navBorder.frame = CGRect(x: 0, y: 44, width: self.navWidth, height: 5)
        navigationBar.layer.addSublayer(navBorder)
        
        setupETA()


    }

    func setupETA() {
        
        self.etaLabel.layer.masksToBounds = true;
        self.etaLabel.layer.cornerRadius = 0.5 * self.etaLabel.bounds.size.width
        
        if (self.defaults.objectForKey("pickupTime") != nil) {
            fullETA = self.defaults.objectForKey("pickupTime") as! String
            print(fullETA)
        }

        if fullETA != "" {

            
            let dateAsString = "\(fullETA)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
            let date = dateFormatter.dateFromString(dateAsString)
            
            dateFormatter.dateFormat = "h:mm"
            let date24 = dateFormatter.stringFromDate(date!)
            etaLabel.text = "\(date24)"
        } else {
            print("For some reason eta not given.")
        }

        
    }
    var labelPositionisLeft = true
    
    func dropTime() {
        etaLabel.hidden = false
        UIView.animateWithDuration(0.7, delay: 0.7, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn , animations: {
            if self.labelPositionisLeft {
                self.etaLabel.center.y = self.view.bounds.height + 200
            }
            else {
                self.etaLabel.center.y = 500
            }
            
            }, completion: nil)
        
        labelPositionisLeft = !labelPositionisLeft
    }
    
    
    @IBAction func cancelRideButton(sender: AnyObject) {
        let currentRideId = defaults.stringForKey("rideID")
        UIView.animateWithDuration(0.5, animations: {
            self.gear.alpha = 1.0
            self.overlay.alpha = 1.0
        })
        
        if self.isRotating == false {
            self.gear.rotate360Degrees(completionDelegate: self)
            // Perhaps start a process which will refresh the UI...

        }

        SCNetwork.deleteRideWithId(currentRideId!,
            completionHandler: {
                success, message in
                
                // can't make UI updates from background thread, so we need to dispatch
                // them to the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // check if registration succeeds
                    if(!success) {
                        // if it failed, display error
//                        self.overlay.alpha = 0.0
//                        self.gear.alpha = 0.0
//                        self.shouldStopRotating = true
                        self.cancelRide()
                    } else {
                        self.cancelRide()
                    }
                })
        })
    }
    
    func refresh() {
        if pickupPresent() {
            print("pickup is good")
        } else {
            self.cancelRide()
        }
        
    }
    
    func pickupPresent()->Bool{
        let pickupTime: AnyObject? = defaults.objectForKey("pickupTime")
        if (pickupTime == nil){
            print("No pickup time")
            return false
        }
        else {
            // check how long ago (in seconds) if greater than 5 hours (18000 sec) return false
            let end = NSDate()
            let dateAsString = "\(pickupTime!)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
            let date = dateFormatter.dateFromString(dateAsString)
            
            let timeInterval: Double = end.timeIntervalSinceDate(date!)
            if timeInterval > 18000 {
                print(timeInterval)
                return false
            } else {
                print(timeInterval)
                return true
            }
        }
    }
    
    func cancelRide() {
        self.defaults.setObject(nil, forKey: "pickupTime")
        self.defaults.setObject(nil, forKey: "rideID")
        self.performSegueWithIdentifier("cancelRideSegue", sender: self)

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
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.gear.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
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
