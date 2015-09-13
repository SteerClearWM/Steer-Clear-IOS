//
//  MapViewController.swift
//  Steer Clear
//
//  Created by Ulises Giacoman on 7/26/15.
//  Copyright (c) 2015 Steer-Clear. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import GoogleMaps
import QuartzCore
import Canvas

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var confirmRideOutlet: UIButton!
    
    @IBOutlet var segmentOutlet: UISegmentedControl!

    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var dropOffButton: UIButton!
    
    @IBOutlet var destinationButton: UIButton!
    @IBOutlet var rideButton: UIButton!
    @IBOutlet var myLocationButtonOutlet: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!

    var globalStartLocation = CLLocationCoordinate2D()
    var globalEndLocation = CLLocationCoordinate2D()
    var changeStart = CLLocationCoordinate2D()
    var changeEnd = CLLocationCoordinate2D()
    var changeStartName = ""
    var changeEndName = ""
    
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker: GMSMarker!
    var endLocationMarker: GMSMarker!
    var locationDetails = ""
    var cameFromSearch = false
    var change = false
    var changePickup = false
    var globalStartName = ""
    var globalEndName = ""
    
    var networkController = Network()
    var settings = Settings()
    
    var geofence = CLCircularRegion()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var popOverOutlet: UIButton!
    @IBOutlet weak var mapsGroupView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    var navWidth = CGFloat()
    var popOverStartY = CGFloat()
    var popOverViewable = false
    var offset = CGFloat()
    var mapgroupStartY = CGFloat()
    var segmentOutletStartY = CGFloat()
    var locationButtonStartY = CGFloat()
    
    var mapgroupEndY = CGFloat()
    var segmentOutletEndY = CGFloat()
    var locationButtonEndY = CGFloat()
    
    @IBAction func segmentControlSwitch(sender: AnyObject) {
        switch segmentOutlet.selectedSegmentIndex
        {
        case 0:
            segmentOutlet.tintColor = settings.spiritGold
            if globalStartName != "" {
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(globalStartLocation,
                    zoom: settings.zoom, bearing: settings.bearing, viewingAngle: settings.viewingAngle))
            }
            
            
        case 1:
            segmentOutlet.tintColor = settings.wmGreen
            if globalEndName != "" {
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(globalEndLocation,
                    zoom: settings.zoom, bearing: settings.bearing, viewingAngle: settings.viewingAngle))
            }
           
            
        default:
            break;
        }
    }

    @IBAction func confirmRideButton(sender: AnyObject) {
        if (pickUpButton.titleLabel!.text == "Select a Pick Up Location") || (dropOffButton.titleLabel!.text == "Select a Drop Off Location") {
            
            let alert = UIAlertController(title: "Trip Error", message: "Please Select a Pick Up and Drop Off Location", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
        else {
            self.performSegueWithIdentifier("sendDetails", sender: self)
        
        }
    }
    
    
    @IBAction func myLocationButton(sender: AnyObject) {
        let myLocation = locationManager.location
        if myLocation != nil {
            if self.geofence.containsCoordinate(myLocation.coordinate){
                self.setupLocationMarker(myLocation.coordinate)
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 17.0, bearing: 30, viewingAngle: 45))
            } else {
                let alert = UIAlertController(title: "Region Error", message: "Your Current Location is outside of Steer Clear's service area. Please select a location inside of our area.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Location Error", message: "Cannot find Current Location.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        if networkController.noNetwork() == false {
            let alert = UIAlertController(title: "Network Connection", message: "Unable to connect to the network.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            segmentOutlet.selectedSegmentIndex = 0
            segmentOutlet.tintColor = settings.spiritGold
            let gpaViewController = GooglePlacesAutocomplete(apiKey: settings.GMSAPIKEY, placeType: .Address)
            gpaViewController.placeDelegate = self
            gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 3219)
            presentViewController(gpaViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func dropOffSearchButton(sender: AnyObject) {
        if networkController.noNetwork() == false {
            let alert = UIAlertController(title: "Network Connection", message: "Unable to connect to the network.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            segmentOutlet.selectedSegmentIndex = 1
            segmentOutlet.tintColor = settings.wmGreen
            let gpaViewController = GooglePlacesAutocomplete(apiKey: settings.GMSAPIKEY, placeType: .Address)
            gpaViewController.placeDelegate = self
            gpaViewController.locationBias = LocationBias(latitude: 37.270821, longitude: -76.709025, radius: 1000)
            presentViewController(gpaViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.navWidth = self.navigationBar.frame.width
        var navBorder = CALayer()
        navBorder.backgroundColor = settings.spiritGold.CGColor
        navBorder.frame = CGRect(x: 0, y: 44, width: self.navWidth, height: 5)
        navigationBar.layer.addSublayer(navBorder)
        
        self.offset = self.mapsGroupView.frame.height
        
        self.mapgroupStartY = self.mapsGroupView.frame.origin.y
        self.mapgroupEndY = self.mapgroupStartY - self.offset
        
        self.segmentOutletStartY = self.segmentOutlet.frame.origin.y
        self.segmentOutletEndY = self.segmentOutletStartY + self.offset
        
        self.locationButtonStartY = self.myLocationButtonOutlet.frame.origin.y
        self.locationButtonEndY = self.locationButtonStartY + offset
    }

    override func viewDidLoad() {
        popOverOutlet.enabled = false
        super.viewDidLoad()

        setupButtons()
        
//        self.popOverStartY = self.popOver.frame.origin.y
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        self.geofence = CLCircularRegion(center: settings.geofenceCenter, radius: 3219, identifier: "serviceGeofence")
        
        if change == true {
            if changePickup == true {
                self.globalStartLocation = changeStart
                self.globalEndLocation = changeEnd
                self.globalStartName = changeStartName
                self.globalEndName = changeEndName
                self.dropOffButton.setTitle("\(globalEndName)", forState: UIControlState.Normal)
                setupLocationMarker(changeStart)
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(changeStart, zoom: 17.0, bearing: 30, viewingAngle: 45))
                changePickup == false
                
                
                self.setupLocationMarker(changeStart)
                endLocationMarker = GMSMarker(position: changeEnd)
                endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
                endLocationMarker.icon = GMSMarker.markerImageWithColor(settings.wmGreen)
                endLocationMarker.title = "Drop Off"
                // endLocationMarker.snippet = "\(locationDetails)"
                println(locationDetails)
                endLocationMarker.opacity = 0.75
                endLocationMarker.map = mapView
                globalEndLocation.latitude = changeEnd.latitude
                globalEndLocation.longitude = changeEnd.longitude
                
            } else {
                println("change pickup is not equal to true")
                self.globalStartLocation = changeStart
                self.globalEndLocation = changeEnd
                self.globalStartName = changeStartName
                self.globalEndName = changeEndName
                self.dropOffButton.setTitle("\(globalEndName)", forState: UIControlState.Normal)
                self.pickUpButton.setTitle("\(globalStartName)", forState: UIControlState.Normal)
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(changeEnd, zoom: 17.0, bearing: 30, viewingAngle: 45))
                changePickup == false
                
                locationMarker = GMSMarker(position: changeStart)
                locationMarker.appearAnimation = kGMSMarkerAnimationPop
                locationMarker.icon = GMSMarker.markerImageWithColor(settings.spiritGold)
                locationMarker.title = "Pick Up"
                locationMarker.opacity = 0.75
                locationMarker.map = mapView
                
                endLocationMarker = GMSMarker(position: changeEnd)
                endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
                endLocationMarker.icon = GMSMarker.markerImageWithColor(settings.wmGreen)
                endLocationMarker.title = "Drop Off"
                endLocationMarker.snippet = "\(locationDetails)"
                println(locationDetails)
                endLocationMarker.opacity = 0.75
                endLocationMarker.map = mapView
                globalEndLocation.latitude = changeEnd.latitude
                globalEndLocation.longitude = changeEnd.longitude

                segmentOutlet.tintColor = settings.wmGreen
                segmentOutlet.selectedSegmentIndex = 1
                

                
            }
            change = false
            
        } else {
            mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
            
        }
        mapView.delegate = self
        popOverOutlet.enabled = true
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as! CLLocation
                if self.geofence.containsCoordinate(myLocation.coordinate){
                    self.setupLocationMarker(myLocation.coordinate)
                    self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 17.0, bearing: 30, viewingAngle: 45))
                } else {
                    let alert = UIAlertController(title: "Region Error", message: "Your Current Location is outside of Steer Clear's service area. Please select a location inside of our area.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            didFindMyLocation = true
        } else {
            println("could not find location")
        }
    }
    //This function detects a long press on the map and places a marker at the coordinates of the long press.
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        //Set variable to latitude of didLongPressAtCoordinate
        var lat = coordinate.latitude
        
        //Set variable to longitude of didLongPressAtCoordinate
        var long = coordinate.longitude
        
        //Feed position to mapMarker
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        if self.geofence.containsCoordinate(coordinate){
            self.setupLocationMarker(coordinate)
        } else {
            let alert = UIAlertController(title: "Region Error", message: "The location you have chosen is outside of Steer Cleer's service area.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons() {
        
        segmentOutlet.tintColor = settings.spiritGold
        
        pickUpButton.layer.shadowOpacity = 0.2
        dropOffButton.layer.shadowOpacity = 0.2
        
        //adds left block to pickup location button (yellow)
        var pickUpBorder = CALayer()
        pickUpBorder.backgroundColor = settings.spiritGold.CGColor
        pickUpBorder.frame = CGRect(x: -20, y: 0, width: 20, height: 36)
        pickUpButton.layer.addSublayer(pickUpBorder)
        
        //dropoff left block (green)
        var dropOffBorder = CALayer()
        dropOffBorder.backgroundColor = settings.wmGreen.CGColor
        dropOffBorder.frame = CGRect(x: -20, y: 0, width: 20, height: 36)
        dropOffButton.layer.addSublayer(dropOffBorder)
        
        myLocationButtonOutlet.layer.shadowOpacity = 0.2
        
    }
    
    
    
    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
        if networkController.noNetwork() == false {
            let alert = UIAlertController(title: "Network Connection", message: "Unable to connect to the network.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            networkController.geocodeAddress(coordinate.latitude, long: coordinate.longitude)
            
            var placesClient: GMSPlacesClient?
            placesClient = GMSPlacesClient()
            
            placesClient!.lookUpPlaceID(networkController.fetchedID, callback: { (place, error) -> Void in
                if error != nil {
                    println("lookup place id query error: \(error!.localizedDescription)")
                    return
                }
                
                if place != nil && self.cameFromSearch == false {
                    if self.segmentOutlet.selectedSegmentIndex == 0 {
                        self.pickUpButton.setTitle("\(place!.name)", forState: UIControlState.Normal)
                        self.globalStartName = place!.name
                        self.globalStartLocation = coordinate
                    } else {
                        self.dropOffButton.setTitle("\(place!.name)", forState: UIControlState.Normal)
                        self.globalEndName = place!.name
                        self.globalEndLocation = coordinate
                    }
                    
                } else {
                    println("No place details for \(self.networkController.fetchedID)")
                }
                self.cameFromSearch = false
                
                if self.segmentOutlet.selectedSegmentIndex == 0 {
                    
                    if self.locationMarker != nil {
                        self.locationMarker.map = nil
                    }
                    self.globalStartLocation.latitude = coordinate.latitude
                    self.globalStartLocation.longitude = coordinate.longitude
                    self.locationMarker = GMSMarker(position: coordinate)
                    self.locationMarker.appearAnimation = kGMSMarkerAnimationPop
                    self.locationMarker.icon = GMSMarker.markerImageWithColor(self.settings.spiritGold)
                    self.locationMarker.title = "Pick Up"
                    self.locationMarker.opacity = 0.75
                    self.locationMarker.map = self.mapView
                
                }
                else {
                  if self.endLocationMarker != nil {
                        self.endLocationMarker.map = nil
                    }
                    self.globalEndLocation.latitude = coordinate.latitude
                    self.globalEndLocation.longitude = coordinate.longitude
                    self.endLocationMarker = GMSMarker(position: coordinate)
                    self.endLocationMarker.appearAnimation = kGMSMarkerAnimationPop
                    self.endLocationMarker.icon = GMSMarker.markerImageWithColor(self.settings.wmGreen)
                    self.endLocationMarker.title = "Drop Off"
                    println(self.locationDetails)
                    self.endLocationMarker.opacity = 0.75
                    self.endLocationMarker.map = self.mapView
                    
                    
                }
                
            })
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sendDetails") {
            
            var tripInfo = segue.destinationViewController as! TripConfirmation;
            
            tripInfo.start = self.globalStartLocation
            tripInfo.end = self.globalEndLocation
            
            tripInfo.startName = self.globalStartName
            tripInfo.endName = self.globalEndName
            
        }
    }
    
}

extension MapViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        place.getDetails { details in
            let tempCoord = CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude)
            if self.geofence.containsCoordinate(tempCoord){
                
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(details.latitude, longitude: details.longitude, zoom: 17.0, bearing: 30, viewingAngle: 45))
                let coordinate = CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude)
                
                if self.segmentOutlet.selectedSegmentIndex == 0 {
                    self.pickUpButton.setTitle("\(place.description)", forState: UIControlState.Normal)
                }
                else {
                    self.dropOffButton.setTitle("\(place.description)", forState: UIControlState.Normal)
                }
                
                self.cameFromSearch = true
                
                self.setupLocationMarker(coordinate)
                
                if self.segmentOutlet.selectedSegmentIndex == 0 {
                    self.globalStartName = place.description
                    self.globalStartLocation = coordinate
                } else {
                    self.globalEndName = place.description
                    self.globalEndLocation = coordinate
                }
                println(details)
            } else {
                let alert = UIAlertController(title: "Region Error", message: "The location you have chosen is outside of Steer Cleer's service area.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
        
        
        self.locationDetails = place.description
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func popUp(sender: AnyObject) {

        
        if !popOverViewable {
            UIView.animateWithDuration(
                0.5,
                animations: {

                    
                    self.mapsGroupView.frame.origin.y = self.mapgroupEndY
                    
                    self.segmentOutlet.frame.origin.y = self.segmentOutletEndY
                    self.myLocationButtonOutlet.frame.origin.y = self.locationButtonEndY
                    self.navigationBar.topItem!.title = "Team";
                    
                },
                completion: nil
            )
            popOverViewable = true
        } else {
            UIView.animateWithDuration(
                0.5,
                animations: {

                    self.mapsGroupView.frame.origin.y = self.mapgroupStartY
                    
                    self.segmentOutlet.frame.origin.y = self.segmentOutletStartY
                    self.myLocationButtonOutlet.frame.origin.y = self.locationButtonStartY
                    
                    self.navigationBar.topItem!.title = "Steer Clear";
                },
                completion: nil
            )
            popOverViewable = false
            
        }

    }
    
    
    @IBAction func ulisesLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://udiscover.me")!)
    }

    @IBAction func ryanLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/RyanBeatty")!)
    }
    @IBAction func kelvinLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://abrokwa.org/")!)        
    }

    @IBAction func nathanLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.nateo.co")!)
    }
    
    @IBAction func corynneLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.corynnedech.com")!)
    }
    @IBAction func milesLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/mformetal")!)
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        self.defaults.setObject(nil, forKey: "sessionCookies")
        self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
    
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}