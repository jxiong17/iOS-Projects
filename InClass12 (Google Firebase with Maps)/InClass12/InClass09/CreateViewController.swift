//
//  CreateViewController.swift
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
import SwiftyJSON
import Alamofire
import GooglePlaces

class CreateViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var citySegmentedController: UISegmentedControl!
    //let apiKey = "AIzaSyAPirhLygv8szPQ97Ezmq8IVrIbEUf7A9U"
    var location = ""
    var long = 0.0
    var lat = 0.0
    var trip = Trip()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if titleTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Missing Fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            print(" this is in the title in \(titleTextField.text!)")
            trip.title = titleTextField.text!
            
            switch citySegmentedController.selectedSegmentIndex {
                
            case 0:
                location = "Charlotte"
                lat = 35.236253
                long = -80.844891
            case 1:
                location = "Greensboro"
                lat = 36.071176
                long = -79.792377
            case 2:
                location = "Raleigh"
                lat = 35.781073
                long = -78.643995
            default:
                lat = 0.0
                long = 0.0
            }
            
            trip.long = long
            trip.lat = lat
            
            let userID = Auth.auth().currentUser?.uid
            
            let rootRef = Database.database().reference().child("users").child(userID!).child("trips").childByAutoId()
            
            trip.key = rootRef.key!
            
            rootRef.setValue(["title": titleTextField.text!, "location": location, "lat": lat, "long": long])
            
            //charlotte 35.236253, -80.844891
            //greensboro 36.071176, -79.792377
            //raleigh 35.781073, -78.643995

        }
        
        let destination = segue.destination as! TripListViewController
        print("this is the trip in createVC inside prepare: \(self.trip.title)")
        destination.selectedTrip = self.trip
    }
    
}

