//
//  ContactsViewController.swift
//  InClass09
//
//  Created by Shehab, Mohamed on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps

class TripListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let apiKey = "AIzaSyAPirhLygv8szPQ97Ezmq8IVrIbEUf7A9U"
    var tripList = [Trip]()
    var selectedTrip: Trip?
    let currentUserID = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register custom cell
        let cellNIb = UINib(nibName: "MyCustomTableViewCell", bundle: nil)
        tableView.register(cellNIb, forCellReuseIdentifier: "newCell")
        
        //create an obsever in viewDidLoad TripVC --DONE--
        //populate the MapVC with markers
        //create trip object with multiple marker array --DONE--
        //add the delete

        let rootRef = Database.database().reference().child("users").child(currentUserID!).child("trips")

        rootRef.observe(.value) { (snapshot) in
            
            if snapshot.value != nil {
                self.tripList.removeAll()
                
                // get trips
                for child in snapshot.children {
                    let trip = Trip()
                    let childSnapshot = child as! DataSnapshot
                    
                    // get trip key
                    trip.key = childSnapshot.key
                    
                    // get data for trip
                    if childSnapshot.hasChild("title") {
                        trip.title = childSnapshot.childSnapshot(forPath: "title").value as! String
                    }
                    if childSnapshot.hasChild("location") {
                        trip.location = childSnapshot.childSnapshot(forPath: "location").value as! String
                    }
                    if childSnapshot.hasChild("lat") {
                        trip.lat = childSnapshot.childSnapshot(forPath: "lat").value as! Double
                    }
                    if childSnapshot.hasChild("long") {
                        trip.long = childSnapshot.childSnapshot(forPath: "long").value as! Double
                    }
                    
                    // get markers
                    if childSnapshot.hasChild("markers") {
                        
                        print("first line of getting markers: \(childSnapshot.childSnapshot(forPath: "markers"))")
                        
                        let markersSnapshot = childSnapshot.childSnapshot(forPath: "markers")
                        
                        for markerChild in markersSnapshot.children {
                            let markerSnapshot = markerChild as! DataSnapshot
                            let marker = Marker()
                            
                            // get marker key
                            marker.key = childSnapshot.key
                            
                            // get data for marker
                            if markerSnapshot.hasChild("title") {
                                marker.title = markerSnapshot.childSnapshot(forPath: "title").value as! String
                            }
                            if markerSnapshot.hasChild("lat") {
                                marker.lat = markerSnapshot.childSnapshot(forPath: "lat").value as! Double
                            }
                            if markerSnapshot.hasChild("long") {
                                marker.long = markerSnapshot.childSnapshot(forPath: "long").value as! Double
                            }
                            
                            trip.markers.append(marker)
                            
                        }
                        
                    } // end of getting markers
                    
                    self.tripList.append(trip)
                    
                } // end of getting trips
                
                self.tableView.reloadData()
                
            } else {
                print("Error when observing Firebase")
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TripsToMap" {
            for marker in selectedTrip!.markers {
                print("- " + marker.title)
            }
            let destination = segue.destination as! MapViewController
            destination.trip = self.selectedTrip
        }
        

    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
        
        print("Log in TripVC: UnwindedSegue ran")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "TripsToMap", sender: self)
        }
        
    
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            AppDelegate.showLogin()
        }catch let signOutError as NSError {
            print("Error: ", signOutError)
        }
        
    }
    
}


//cell creation
extension TripListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! MyCustomTableViewCell
        
        cell.titleLabel.text = self.tripList[indexPath.row].title
        cell.locationLabel.text = self.tripList[indexPath.row].location
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rootRef = Database.database().reference().child("users").child(currentUserID!).child("trips")
        
        
        selectedTrip = tripList[indexPath.row]
        
        tableView.reloadData()
        
        performSegue(withIdentifier: "TripsToMap", sender: self)
    }
    
}

//interface
extension TripListViewController: CustomTVCellDelegate {
    
    func delete(cell: UITableViewCell) {
        
        //delete cell
        let indexPath = self.tableView.indexPath(for: cell)
        
        print("this is the indexpath \(indexPath!)")
        
        let rootRef = Database.database().reference().child("users").child(currentUserID!).child("trips")
        
        print(tripList[indexPath![1]].key)
        rootRef.child(tripList[indexPath![1]].key).setValue(nil)
        
        tableView.reloadData()
    }
}
