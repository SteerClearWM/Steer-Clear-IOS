//
//  Network.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 7/26/15.
//  Copyright (c) 2015 Paradoxium. All rights reserved.
//

import Foundation



class Register {
    func sendRequest() {
        /* Configure session, choose between:
        * defaultSessionConfiguration
        * ephemeralSessionConfiguration
        * backgroundSessionConfigurationWithIdentifier:
        And set session-wide properties, such as: HTTPAdditionalHeaders,
        HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
        */
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
        My API (POST http://127.0.0.1:5000/register)
        */
        
        var URL = NSURL(string: "http://127.0.0.1:5000/register")
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "POST"
        
        // Form URL-Encoded Body
        
        let bodyParameters = [
            "username": "smurf",
            "password": "dog",
        ]
        let bodyString = self.stringFromQueryParameters(bodyParameters)
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        /* Start a new Task */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                println("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                println("URL Session Task Failed: %@", error.localizedDescription);
            }
        })
        task.resume()
    }
    
    /**
    This creates a new query parameters string from the given NSDictionary. For
    example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
    string will be @"day=Tuesday&month=January".
    @param queryParameters The input dictionary.
    @return The created parameters string.
    */
    func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            var part = NSString(format: "%@=%@",
                name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
                value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            parts.append(part as String)
        }
        return "&".join(parts)
    }
    
    /**
    Creates a new URL by adding the given query parameters.
    @param URL The input URL.
    @param queryParameters The query parameter dictionary to add.
    @return A new NSURL.
    */
    func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString!, self.stringFromQueryParameters(queryParameters))
        return NSURL(string: URLString as String)!
    }
}

class Login {
    func sendRequest() {
        /* Configure session, choose between:
        * defaultSessionConfiguration
        * ephemeralSessionConfiguration
        * backgroundSessionConfigurationWithIdentifier:
        And set session-wide properties, such as: HTTPAdditionalHeaders,
        HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
        */
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
        My API (2) (POST http://127.0.0.1:5000/login)
        */
        
        var URL = NSURL(string: "http://127.0.0.1:5000/login")
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "POST"
        
        // Form URL-Encoded Body
        
        let bodyParameters = [
            "username": "smurfs",
            "password": "dog",
        ]
        let bodyString = self.stringFromQueryParameters(bodyParameters)
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        /* Start a new Task */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                println("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                println("URL Session Task Failed: %@", error.localizedDescription);
            }
        })
        task.resume()
    }
    
    /**
    This creates a new query parameters string from the given NSDictionary. For
    example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
    string will be @"day=Tuesday&month=January".
    @param queryParameters The input dictionary.
    @return The created parameters string.
    */
    func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            var part = NSString(format: "%@=%@",
                name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
                value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            parts.append(part as String)
        }
        return "&".join(parts)
    }
    
    /**
    Creates a new URL by adding the given query parameters.
    @param URL The input URL.
    @param queryParameters The query parameter dictionary to add.
    @return A new NSURL.
    */
    func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString!, self.stringFromQueryParameters(queryParameters))
        return NSURL(string: URLString as String)!
    }
}


class AddRide {
    func sendRequest() {
        var postData = NSMutableData(data: "num_passengers=3".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&start_latitude=37.273485".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&start_longitude=-76.719628".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&end_latitude=37.280893".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&end_longitude=-76.719691".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&pickup_time=Sun, 07 Jun 2015 02:21:58 GMT".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&travel_time=171".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("&dropoff_time=Sun, 07 Jun 2015 02:24:49 GMT".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        var request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/api/rides")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                println(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                println(httpResponse)
            }
        })
        
        dataTask.resume()
    }
}

class ClearQueue {
    func sendRequest(){
        var request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/api/clear")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                println(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                println(httpResponse)
            }
        })
        
        dataTask.resume()
        
    }
}

class Logout {
    func sendRequest(){
        var request = NSMutableURLRequest(URL: NSURL(string: "http://127.0.0.1:5000/logout")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                println(error)
            } else {
                let httpResponse = response as? NSHTTPURLResponse
                println(httpResponse)
            }
        })
        
        dataTask.resume()
        
    }
}


