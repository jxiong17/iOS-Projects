//
//  MapViewController.swift
//  InClass09
//
//  Created by Xiong, Jeff on 4/17/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps
import CoreLocation
import GooglePlaces
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    @IBOutlet weak var ViewMap: GMSMapView!
    let apiKey = "AIzaSyCjQlEN9SKDCtC30zy7grp-lyhPjEv792Q"
    
    let locationManager = CLLocationManager()
    
    var destination: GMSPlace?
    var currentLocation: CLLocation?
    
    let destLat = 35.448161 // TEST - Delete later
    let destLong = -81.083148 // TEST - Delete later
    
    
    //array of points object
    var points = [Point]()
    
    //local variables for line
    var oldPolylineArr = [GMSPolyline]()
    
    
    var polylinePoints = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        enableBasicLocationServices()
        
        self.ViewMap.delegate = self
        
    }
    
    func enableBasicLocationServices() {
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            //disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            //enableMyWhenInUseFeatures()
            self.locationManager.startUpdatingLocation()
            break
        }
    }
    
    func setupForLocationUpdates() {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0
        self.locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func directionClicked(_ sender: Any) {
        
        // Present the Autocomplete view controller when the button is pressed.
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @IBAction func clearClicked(_ sender: Any) {
        
        fromLabel.text = ""
        toLabel.text = ""
        durationLabel.text = ""
        distanceLabel.text = ""
        
        //clear lines
        for p in (0 ..< oldPolylineArr.count) {
            oldPolylineArr[p].map = nil
        }
        
        //clear markers
        ViewMap.clear()
        
        //clear array
        points.removeAll()
        polylinePoints.removeAll()

    }

}

extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name!)")
        print("Place ID: \(place.placeID!)")
        print("Place lat: \(place.coordinate.latitude)")
        print("Place long: \(place.coordinate.longitude)")
        dismiss(animated: true) {
            self.destination = place
            let currentLat = self.currentLocation!.coordinate.latitude
            let currentLong = self.currentLocation!.coordinate.longitude

            
            Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLat),\(currentLong)&destination=place_id:\(place.placeID!)&key=\(self.apiKey)").responseJSON(completionHandler: { (response) in
                if response.result.isSuccess {
                    
                    //get the root
                    let data = JSON(response.result.value!)
                    print("data: \(data)")
                    let route = data["routes"].arrayValue
                    let routeArray = route[0].dictionaryValue
                    let legs = routeArray["legs"]!.arrayValue
                    let legsArray = legs[0].dictionaryValue
                    
                    
                    //get duration
                    let duration = legsArray["duration"]?.dictionaryValue
                    self.durationLabel.text = duration!["text"]!.stringValue
                    
                    //get distance
                    let distance = legsArray["distance"]?.dictionaryValue
                    self.distanceLabel.text = distance!["text"]!.stringValue
                    
                    
                    //get from
                    self.fromLabel.text = legsArray["start_address"]!.stringValue
                    
                    //get to
                    self.toLabel.text = legsArray["end_address"]!.stringValue
                    
                    //get points for polyline
                    let steps = legsArray["steps"]!.arrayValue
                    
                    for i in 0...steps.count - 1  {
                        
                        let point = Point()
  
                        let stepsArray = steps[i].dictionaryValue
                        let endLocation = stepsArray["end_location"]!.dictionaryValue
                        point.lat = endLocation["lat"]!.doubleValue
                        point.long = endLocation["lng"]!.doubleValue
                    
                        self.points.append(point)
                        
                    }
                    //print("all points \(self.points.count)")
                    
                    //parse the json and add in to array strings points
                    for i in 0...steps.count - 1  {

                        let stepsArray = steps[i].dictionaryValue
                        
                        let polyline = stepsArray["polyline"]!.dictionaryValue
                        
                        self.polylinePoints.append(polyline["points"]!.stringValue)
                        
                    }

                    
                    //display the polyline
                    for i in 0...self.polylinePoints.count - 1 {
                        
                        let path = GMSPath.init(fromEncodedPath: self.polylinePoints[i])
                        let rectangle = GMSPolyline(path: path)
                        rectangle.strokeWidth = 5.0
                        rectangle.map = self.ViewMap
                        //Step 3:
                        self.oldPolylineArr.append(rectangle)
                        //code to fit both views of markers
                        
                    }


                    //display the polyline path for bounds
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong))
                    for i in 0...self.points.count - 1 {
                        //print("point #\(i): \(self.points[i].lat), \(self.points[i].long)")
                        path.add(CLLocationCoordinate2D(latitude: self.points[i].lat, longitude: self.points[i].long))
                    }
                    
                    //display the orgin and distination markers
                    let orginMarker = GMSMarker()
                    let distinationMarker = GMSMarker()
                    orginMarker.position = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong)
                    orginMarker.map = self.ViewMap
                    distinationMarker.position = CLLocationCoordinate2D(latitude: self.points[self.points.count - 1].lat, longitude: self.points[self.points.count - 1].long)
                    distinationMarker.map = self.ViewMap

                    let bounds = GMSCoordinateBounds(path: path)
                    self.ViewMap.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))

                } else {
                    print("Error in Alamofire request")
                }
            })

        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            //disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            setupForLocationUpdates()
            //enableMyWhenInUseFeatures()
            break
            
        case .notDetermined:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        print("location: \(location!)")
        currentLocation = location!
        
        self.ViewMap.camera = GMSCameraPosition.camera(withTarget: location!.coordinate, zoom: 12)
        
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
 
    }
}
