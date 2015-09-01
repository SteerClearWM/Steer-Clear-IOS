//
//  ViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 5/15/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextbox: UITextField!
    @IBOutlet weak var passwordTextbox: UITextField!
    @IBOutlet weak var phoneTextbox: UITextField!

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!

    
    @IBOutlet weak var usernameIcon: UILabel!
    @IBOutlet weak var passwordIcon: UILabel!
    @IBOutlet weak var phoneIcon: UILabel!
    
    @IBOutlet weak var usernameUnderlineLabel: UIView!
    @IBOutlet weak var phoneUnderlineLabel: UIView!
    @IBOutlet weak var passwordUnderlineLabel: UIView!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createAnAccountLabel: UIButton!
    
    @IBOutlet weak var steerClearLogo: UIImageView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var isRotating = false
    var shouldStopRotating = false
    var offset: CGFloat = 500
    var myString:NSString = "Don't have an account? REGISTER"
    var cancelNSString:NSString = "Cancel"
    var cancelMutableString = NSMutableAttributedString()
    var registerMutableString = NSMutableAttributedString()
    var spiritGold = UIColor(hue: 0.1167, saturation: 0.85, brightness: 0.94, alpha: 1.0) /* #f0b323 */
    
    var startX = CGFloat()
    var startXphoneTextBox = CGFloat()
    var startXphonelabel = CGFloat()
    var startXphoneUnderline = CGFloat()
    var endXphoneTextBox = CGFloat()
    var endXphonelabel = CGFloat()
    var endXphoneUnderline = CGFloat()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.usernameTextbox.delegate = self;
        self.passwordTextbox.delegate = self;
        if self.defaults.stringForKey("lastUser") != nil {
            self.usernameTextbox.text = self.defaults.stringForKey("lastUser")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewDidAppear(animated: Bool) {

        self.startXphoneTextBox = self.phoneTextbox.frame.origin.x
        self.startXphonelabel = self.phoneLabel.frame.origin.x
        self.startXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
        
        self.phoneTextbox.frame.origin.x = startXphoneTextBox - self.offset
        self.phoneLabel.frame.origin.x = startXphonelabel - self.offset
        self.phoneUnderlineLabel.frame.origin.x = startXphoneUnderline - self.offset
        
        self.endXphoneTextBox = self.phoneTextbox.frame.origin.x
        self.endXphonelabel = self.phoneLabel.frame.origin.x
        self.endXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
        
        self.startX = self.loginBtn.frame.origin.x
        
        phoneTextbox.hidden = true
        phoneLabel.hidden = true
        phoneUnderlineLabel.hidden = true
        checkUser()
        
        usernameTextbox.delegate = self
        passwordTextbox.delegate = self
        self.usernameTextbox.nextField = self.passwordTextbox
        

    }
    
    // unwind segue method so that you can cancel registration view controller
    @IBAction func cancelToLoginViewController(segue:UIStoryboardSegue) {
        
    }
    /*
        loginButton
        -----------
        Attempts to log the user into the system
    */
    @IBAction func login(sender: AnyObject) {
        // grab username and password fields and check if they are not null
        
        var username = usernameTextbox.text
        var password = passwordTextbox.text
        var phone = phoneTextbox.text
        if (username!.isEmpty) || (password!.isEmpty) {
            jiggleLogin()
            self.displayAlert("Form Error", message: "Please make sure you have filled all fields.")
        } else {
            if loginBtn.titleLabel?.text == "LOGIN" {
                if self.isRotating == false {
                    self.steerClearLogo.rotate360Degrees(completionDelegate: self)
                    // Perhaps start a process which will refresh the UI...
                    self.shouldStopRotating = true
                    self.isRotating = true
                }
                // else try to log the user in
                SCNetwork.login(
                    username,
                    password: password,
                    completionHandler: {
                        success, message in
                        
                        if(!success) {
                            // can't make UI updates from background thread, so we need to dispatch
                            // them to the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                // login failed, display error
                                self.jiggleLogin()
                                self.displayAlert("Login Error", message: message)
                                self.shouldStopRotating = true
                            })
                        }
                        else {
                            // can't make UI updates from background thread, so we need to dispatch
                            // them to the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                self.shouldStopRotating = true
                                self.phoneTextbox.hidden = true
                                self.phoneLabel.hidden = true
                                self.phoneUnderlineLabel.hidden = true
                                
                                self.defaults.setObject("\(username)", forKey: "lastUser")
                                self.performSegueWithIdentifier("loginRider", sender: self)
                            })
                        }
                })
            }
            else {
                //lets register
                if (phone!.isEmpty) {
                    jiggleLogin()
                    self.displayAlert("Form Error", message: "Please make sure you have filled all fields.")
                } else {
                // attempt to register user
                SCNetwork.register(
                    username,
                    password: password,
                    phone: phone,
                    completionHandler: {
                        success, message in
                        
                        // can't make UI updates from background thread, so we need to dispatch
                        // them to the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            // check if registration succeeds
                            if(!success) {
                                // if it failed, display error
                                self.displayAlert("Registration Error", message: message)
                            } else {
                                // if it succeeded, log user in and change screens to
                                println("Logging in")
                                SCNetwork.login(
                                    username,
                                    password: password,
                                    completionHandler: {
                                        success, message in
                                        
                                        if(!success) {
                                            //can't make UI updates from background thread, so we need to dispatch
                                            // them to the main thread
                                            dispatch_async(dispatch_get_main_queue(), {
                                                // login failed, display alert
                                                self.displayAlert("Login Error", message: message)
                                            })
                                        }
                                        else {
                                            //can't make UI updates from background thread, so we need to dispatch
                                            // them to the main thread
                                            dispatch_async(dispatch_get_main_queue(), {
                                                self.defaults.setObject("\(username)", forKey: "lastUser")
                                                self.performSegueWithIdentifier("loginRider", sender: self)
                                            })
                                        }
                                })
                            }
                        })
                    }
                )
            }
            
        }
        }
        
    }
        
       
    /*
    registerButton
    --------------
    Redirects user to Registration Page
    
    */
    @IBAction func registerButton(sender: AnyObject) {
        let customColor = UIColor(hue: 0.4444, saturation: 0.8, brightness: 0.34, alpha: 1.0) /* #115740 */
        let startXphoneTextBox = self.phoneTextbox.frame.origin.x
        let startXphonelabel = self.phoneLabel.frame.origin.x
        let startXphoneUnderline = self.phoneUnderlineLabel.frame.origin.x
        
        if createAnAccountLabel.titleLabel!.text == "Don't have an account? REGISTER" {
            
            phoneTextbox.hidden = false
            phoneLabel.hidden = false
            phoneUnderlineLabel.hidden = false
            
            UIView.animateWithDuration(
                0.5,
                animations: {
                    self.phoneTextbox.frame.origin.x = self.startXphoneTextBox
                    self.phoneLabel.frame.origin.x = self.startXphonelabel
                    self.phoneUnderlineLabel.frame.origin.x = self.startXphoneUnderline
                },
                completion: nil
            )
            
            createAnAccountLabel.setAttributedTitle(self.cancelMutableString, forState: UIControlState.Normal)
            loginBtn.setTitle("REGISTER", forState: UIControlState.Normal)
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME (treveley)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            loginBtn.backgroundColor = UIColor.whiteColor()
            loginBtn.setTitleColor(customColor , forState: UIControlState.Normal)
        }
        else {
            
            UIView.animateWithDuration(
                0.5,
                animations: {
                    self.phoneTextbox.frame.origin.x = self.endXphoneTextBox
                    self.phoneLabel.frame.origin.x = self.endXphonelabel
                    self.phoneUnderlineLabel.frame.origin.x = self.endXphoneUnderline
                },
                completion: nil
            )
            
            createAnAccountLabel.setAttributedTitle(registerMutableString, forState: UIControlState.Normal)
            loginBtn.setTitle("LOGIN", forState: UIControlState.Normal)
            
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            loginBtn.backgroundColor = UIColor.clearColor()
            loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
       
    }
    
    
    
    /*
    design
    ------
    Implements the following styles to the username and password textboxes in the Storyboard ViewController:
    
        UsernameTextbox: change placeholder text white
        PasswordTextbox: change placeholder text white
    
    */
    func design() {
        // Colors
        let customColor = UIColor(hue: 0.1056, saturation: 0.5, brightness: 0.72, alpha: 0.5) /* #b9975b */
        self.loginBtn.layer.borderWidth = 2
        self.loginBtn.layer.borderColor = UIColor.whiteColor().CGColor

        // Username text box
        usernameTextbox.layer.masksToBounds = true
        self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:self.usernameTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Password text box
        self.passwordTextbox.attributedPlaceholder = NSAttributedString(string:self.passwordTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.phoneTextbox.attributedPlaceholder = NSAttributedString(string:self.phoneTextbox.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        
        
        cancelMutableString = NSMutableAttributedString(string: cancelNSString as String, attributes: [NSFontAttributeName:UIFont(name: "Avenir Next", size: 15.0)!])
        
        registerMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Avenir Next", size: 15.0)!])
        
        registerMutableString.addAttribute(NSForegroundColorAttributeName, value: spiritGold, range: NSRange(location:23,length:8))
        
        createAnAccountLabel.setAttributedTitle(registerMutableString, forState: UIControlState.Normal)
        
    }
    
    func checkUser() {
        let customColor = UIColor(hue: 0.4444, saturation: 0.8, brightness: 0.34, alpha: 1.0) /* #115740 */
        
        if isAppAlreadyLaunchedOnce() == false {
            phoneTextbox.hidden = false
            phoneLabel.hidden = false
            phoneUnderlineLabel.hidden = false
            
            self.phoneTextbox.frame.origin.x = self.startXphoneTextBox
            self.phoneLabel.frame.origin.x = self.startXphonelabel
            self.phoneUnderlineLabel.frame.origin.x = self.startXphoneUnderline
            
            createAnAccountLabel.setAttributedTitle(self.cancelMutableString, forState: UIControlState.Normal)
            loginBtn.setTitle("REGISTER", forState: UIControlState.Normal)
            self.usernameTextbox.attributedPlaceholder = NSAttributedString(string:"W&M USERNAME (treveley)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            loginBtn.backgroundColor = UIColor.whiteColor()
            loginBtn.setTitleColor(customColor , forState: UIControlState.Normal)
        }
        else {
            println("not new user lets see if logged in")
            SCNetwork.checkIndex(
                {
                    success, message in
                    
                    if(!success) {
                        // can't make UI updates from background thread, so we need to dispatch
                        // them to the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            println("User not logged in, let user log in.")
                            
                        })
                    }
                    else {
                        // can't make UI updates from background thread, so we need to dispatch
                        // them to the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        })
                    }
            })
        }
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        if let isAppAlreadyLaunchedOnce = self.defaults.stringForKey("isAppAlreadyLaunchedOnce"){
            println("App already launched")
            return true
        }
        else {
            defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            println("App launched first time")
            return false
        }
    }
    
    /* 
    displayAlert
    ------------
    Handles user alerts. For example, when Username or Password is required but not entered.
    
    */
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.steerClearLogo.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let nextField = textField.nextField {
            nextField.becomeFirstResponder()
        }
        if (textField.returnKeyType==UIReturnKeyType.Go)
        {
        textField.resignFirstResponder() // Dismiss the keyboard
        loginBtn.sendActionsForControlEvents(.TouchUpInside)
        }
        return true
    }
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func jiggleLogin() {
        UIView.animateWithDuration(
            0.1,
            animations: {
                self.loginBtn.frame.origin.x = self.startX - 10
            },
            completion: { finish in
                UIView.animateWithDuration(
                    0.1,
                    animations: {
                        self.loginBtn.frame.origin.x = self.startX + 10
                    },
                    completion: { finish in
                        UIView.animateWithDuration(
                            0.1,
                            animations: {
                                self.loginBtn.frame.origin.x = self.startX
                            }
                        )
                    }
                )
            }
        )
    }
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            UIView.animateWithDuration(0.5, animations: {
                self.steerClearLogo.alpha = 0.0

            })
            
            self.usernameTextbox.frame.origin.y -= 100
            self.usernameIcon.frame.origin.y -= 100
            self.usernameUnderlineLabel.frame.origin.y -= 100
            
            self.passwordTextbox.frame.origin.y -= 100
            self.passwordIcon.frame.origin.y -= 100
            self.passwordUnderlineLabel.frame.origin.y -= 100
            
            self.phoneTextbox.frame.origin.y -= 100
            self.phoneIcon.frame.origin.y -= 100
            self.phoneUnderlineLabel.frame.origin.y -= 100


        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.usernameTextbox.frame.origin.y += 100
            self.usernameIcon.frame.origin.y += 100
            self.usernameUnderlineLabel.frame.origin.y += 100
            
            self.passwordTextbox.frame.origin.y += 100
            self.passwordIcon.frame.origin.y += 100
            self.passwordUnderlineLabel.frame.origin.y += 100
            
            self.phoneTextbox.frame.origin.y += 100
            self.phoneIcon.frame.origin.y += 100
            self.phoneUnderlineLabel.frame.origin.y += 100
            
            
            UIView.animateWithDuration(0.5, animations: {
                self.steerClearLogo.alpha = 1.0
                
            })
        }
    }
    
}

