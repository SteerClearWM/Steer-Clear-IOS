//
//  SCNetwork.swift
//  Steer Clear
//
//  Created by Ryan Beatty on 8/18/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import Foundation
import SwiftyJSON

// hostname of server
let HOSTNAME = "https://steerclear.wm.edu/"
//let HOSTNAME = "http://localhost:5000/"

// api url routes
let REGISTER_ROUTE = "register"
let LOGIN_ROUTE = "login"
let LOGOUT_ROUTE = "logout"
let RIDE_REQUEST_ROUTE = "api/rides"
let CLEAR_ROUTE = "clear"
let DELETE_ROUTE = "api/rides/"
let TIMELOCK_ROUTE = "api/timelock"

// complete api route strings
let REGISTER_URL_STRING = HOSTNAME + REGISTER_ROUTE
let LOGIN_URL_STRING = HOSTNAME + LOGIN_ROUTE
let LOGOUT_URL_STRING = HOSTNAME + LOGOUT_ROUTE
let RIDE_REQUEST_URL_STRING = HOSTNAME + RIDE_REQUEST_ROUTE
let ClEAR_URL_STRING = HOSTNAME + CLEAR_ROUTE
let DELETE_URL_STRING = HOSTNAME + DELETE_ROUTE
let TIMELOCK_STRING = HOSTNAME + TIMELOCK_ROUTE

class SCNetwork: NSObject {
    
    
    /*
    register
    --------
    Attempts to register a new user into the system
    
    :username:              W&M username string
    :password:              W&M password string
    :phone:                 User phone number (e.x. 1xxxyyyzzzz) NOTE: there is no plus sign
    :completionHandler:     Callback function called when response is gotten. Function that takes a boolean stating
    whether the register request succeeded or not. If the request failed, the :message: parameter
    will contain an error message
    */
    class func register(username: String, password: String, phone: String, completionHandler: (success: Bool, message: String) -> ()) {
        
        // create register url
        let registerUrl = NSURL(string: REGISTER_URL_STRING)
        
        // initialize url request object
        let request = NSMutableURLRequest(URL: registerUrl!)
        
        // set http method to POST and encode form parameters
        request.HTTPMethod = "POST"
        request.HTTPBody = NSMutableData(data:
            "username=\(username)&password=\(password)&phone=%2B1\(phone)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // initialize session object create http request task
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil) {
                completionHandler(success: false, message: "There was a network error while registering")
                return
            }
            
            // if there is no response, request failed
            if(response == nil) {
                completionHandler(success: false, message: "No response from server. Please try again later.")
                return
            }
            
            // else check the request status code to see if registering succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 200:
                completionHandler(success: true, message: "Registered!")
            case 409:
                completionHandler(success: false, message: "The username or phone you specified already exists")
            case 400:
                completionHandler(success: false, message: "The username, password, or phone number were entered incorrectly")
            default:
                print("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while registering")
            }
        })
        
        // start task
        task.resume()
    }
    
    
    /*
    checkCookie
    ----------
    Checks whether a cookie has been saved. A cookie is saved when registering and when logging in. It is cleared on logout.
    
    */
    class func checkCookie(completionHandler: (success: Bool, message: String) -> ()) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let data: NSData? = defaults.objectForKey("sessionCookies") as? NSData
        
        switch(data) {
        case nil:
            print("User not logged in, defaults empty")
            completionHandler(success: false, message: "User not logged in, defaults empty")
        default:
            print("Cookies found")
            completionHandler(success: true, message: "Cookies found")
        }
    }
    
    /*
    login
    -----
    Attempts to log the user in
    
    :username:          the username string of the user attempting to login
    :password:          the password string of the user attempting to login
    :completionHandler: the function to call when the response is recieved. Takes a
    boolean flag signifying if the request succeeded and a message string
    */
    class func login(username: String, password: String, completionHandler: (success: Bool, message: String) -> ()) {
        // create login url
        let loginUrl = NSURL(string: LOGIN_URL_STRING)
        
        // initialize url request object
        let request = NSMutableURLRequest(URL: loginUrl!)
        
        // set http method to POST and encode form parameters
        request.HTTPMethod = "POST"
        request.HTTPBody = NSMutableData(data:
            "username=\(username)&password=\(password)".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // initialize session object create http request task
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil) {
                completionHandler(success: false, message: "There was a network error while logging in")
                return
            }
            
            // if there is no response, request failed
            if(response == nil) {
                completionHandler(success: false, message: "No response from server.")
                return
            }
            
            // else check the request status code to see if login succeeded
            let httpResponse = response as! NSHTTPURLResponse
            
            
            switch(httpResponse.statusCode) {
            case 200:
                
                completionHandler(success: true, message: "Logged in!")
            case 400:
                completionHandler(success: false, message: "Invalid username or password.")
            default:
                print("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while logging in.")
            }
        })
        
        // start task
        task.resume()
    }
    
    /*
    requestRide
    -----------
    Attempts to make a new ride request
    
    :startLat:          starting latitude coordinate
    :startLong:         starting longitude coordinate
    :endLat:            ending latitude coordinate
    :endLong:           ending longitude coordinate
    :numPassengers:     number of passengers in the ride request
    :completionHandler: callback
    */
    class func requestRide(startLat: String, startLong: String, endLat: String, endLong: String, numPassengers: String, completionHandler: (success: Bool, needLogin: Bool, message: String, ride: Ride?)->()) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        // create rideRequest url
        let rideRequestUrl = NSURL(string: RIDE_REQUEST_URL_STRING)
        
        // build form data string
        let formDataString = "start_latitude=\(startLat)" +
            "&start_longitude=\(startLong)" +
            "&end_latitude=\(endLat)" +
            "&end_longitude=\(endLong)" +
        "&num_passengers=\(numPassengers)"
        
        // initialize url request object
        let request = NSMutableURLRequest(URL: rideRequestUrl!)
        
        // set http method to POST and encode form parameters
        request.HTTPMethod = "POST"
        request.HTTPBody = NSMutableData(data: formDataString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // initialize session object create http request task
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil || response == nil || data == nil) {
                completionHandler(success: false, needLogin: false, message: "There was a network error while requesting a ride \(error)", ride:nil)
                return
            }
            
            // else check the request status code to see if login succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 201:
                // get json object
                let json = JSON(data: data!)
                
                // get ride request data
                let id = json["ride"]["id"].int
                let numPassengers = json["ride"]["num_passengers"].int
                let pickupAddress = json["ride"]["pickup_address"].string
                let dropoffAddress = json["ride"]["dropoff_address"].string
                let pickupTime = json["ride"]["pickup_time"].string
                
                // check for error in json response
                if id == nil || numPassengers == nil || pickupAddress == nil || dropoffAddress == nil || pickupTime == nil {
                    completionHandler(success:false, needLogin:true, message: "There was an error while requesting a ride \(httpResponse.statusCode)", ride: nil)
                }
                
                // create ride object
                let ride = Ride(id: id!, numPassengers: numPassengers!, pickupAddress: pickupAddress!, dropoffAddress: dropoffAddress!, pickupTime: pickupTime!)
                
                defaults.setObject(pickupTime, forKey: "pickupTime")
                defaults.setObject(id, forKey: "rideID")
                
                completionHandler(success: true, needLogin: false, message: "Ride requested!", ride: ride)
            case 400:
                completionHandler(success: false, needLogin: false, message: "You've entered some ride information incorrectly", ride: nil)
            case 401:
                completionHandler(success: false, needLogin: true, message: "Please Login", ride: nil)
            case 503:
                completionHandler(success: false, needLogin: true, message: "Steer Clear is currently not operating. Please try again during operating hours.", ride: nil)
            default:
                completionHandler(success: false, needLogin: false, message: "There was an error while requesting a ride. \(httpResponse.statusCode)", ride: nil)
            }
        })
        
        // start task
        task.resume()
    }
    
    
    /*
    deleteRideWithId
    --------------
    Attempts to delete current ride request
    
    :rideId:                Current Ride Id
    :completionHandler:     Callback function called when response is gotten.
    Function that takes a boolean
    
    */
    class func deleteRideWithId(rideId: String, completionHandler: (success: Bool, message: String) -> ()) {
        
        // create delete url
        let deleteUrl = NSURL(string: DELETE_URL_STRING + "\(rideId)")
        
        // initialize url request object
        let request = NSMutableURLRequest(URL: deleteUrl!)
        
        // set http method to DELETE
        request.HTTPMethod = "DELETE"
        
        // initialize session object create http request task
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            // if there was an error, request failed
            if(error != nil || response == nil) {
                completionHandler(success: false, message: "There was a network error while canceling your ride request")
                return
            }
            
            // else check the request status code to see if registering succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 204:
                completionHandler(success: true, message: "Canceled your ride request!")
            case 404:
                completionHandler(success: false, message: "You have no current ride requests")
            default:
                print("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while canceling your ride request")
            }
        })
        
        // start task
        task.resume()
    }
    
    /*
    logout
    ------
    Attempts to log the user out
    
    :completionHandler: callback method that takes a success flag and a string message
    */
    class func logout(completionHandler: (success: Bool, message: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: LOGOUT_URL_STRING)!)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            // if there was an error, request failed
            if(error != nil || response == nil || data == nil) {
                completionHandler(success: false, message: "There was a network error while logging out")
                return
            }
            
            // else check the request status code to see if logging out succeeded
            let httpResponse = response as! NSHTTPURLResponse
            switch(httpResponse.statusCode) {
            case 200:
                completionHandler(success: true, message: "Logged out!")
            default:
                print("Status Code received: \(httpResponse.statusCode)")
                completionHandler(success: false, message: "There was an error while logging out")
            }
        })
        
        dataTask.resume()
    }
    
    /*
    timelock
    ------
    Checks to see if Steer Clear service is running
    
    
    */
    class func timelock()->Bool{
        
        // Get today's date
        let date = NSDate()
        let cal_formatter  = NSDateFormatter()
        cal_formatter.dateFormat = "yyyy-MM-dd-HH"
        let calender_date = cal_formatter.stringFromDate(date)
        
        
        // Days are Monday = 1, Tuesday = 2, etc...
        let days = [1,5,6]
        let thurs_hours = [20,21,22,23]
        let weekend_hours = [20,21,22,23,24,1]
        
        if let dateInfo:[Int]? = getDateInfo(calender_date) {
            //If Thursday
            if dateInfo![0] == 4 && thurs_hours.contains(dateInfo![1]){
                print("We in thurs business")
                return true
                
            }
            //If Friday or Saturday
            if (days.contains(dateInfo![0])) && (weekend_hours.contains(dateInfo![1])){
                print("We in weekend business")
                return true
            }
            return false
        }
    }
    
    class func getDateInfo(today:String)->[Int]? {
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH"
        if let todayDate = formatter.dateFromString(today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let myComponents = myCalendar.components([.Weekday, .Hour], fromDate: todayDate)
            let dateInfo = [myComponents.weekday, myComponents.hour]
            return dateInfo
        } else {
            return nil
        }
    }
    
    

}