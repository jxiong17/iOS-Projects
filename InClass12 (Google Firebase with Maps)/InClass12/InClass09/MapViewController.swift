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

class MapViewController: UIViewController {

    var trip: Trip?
    
    @IBOutlet weak var ViewMap: GMSMapView!
    let apiKey = "AIzaSyAPirhLygv8szPQ97Ezmq8IVrIbEUf7A9U"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("Log the MapVC trip title is: \(trip!.title)")
        
        let location = GMSCameraPosition.camera(withLatitude: trip!.lat, longitude: trip!.long, zoom: 14)
        self.ViewMap.camera = location
        self.ViewMap.delegate = self
        
        for marker in trip!.markers {
            print("marker = \(marker.title)")
            let mapMarker = GMSMarker()
            mapMarker.position = CLLocationCoordinate2D(latitude: marker.lat, longitude: marker.long)
            mapMarker.title = marker.title
            mapMarker.map = self.ViewMap
            
        }
        
    }

}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        let marker = GMSMarker()
        marker.position = coordinate
        marker.map = self.ViewMap
        
        
        let alert = UIAlertController(title: "", message: "Please Enter Name of Location", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            UITextField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            let textField = alert.textFields![0]
            print("Log: The text is \(textField.text!)")
            marker.title = textField.text
            
            //firebase
            print(marker.position.latitude as Double)
            
            let userID = Auth.auth().currentUser?.uid
            
            let rootRef = Database.database().reference().child("users").child(userID!).child("trips").child(self.trip!.key).child("markers").childByAutoId()
            
            rootRef.setValue(["title": textField.text!, "lat": marker.position.latitude as Double, "long": marker.position.longitude as Double])
            
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
    }
}
