//
//  ContactsViewController.swift
//  InClass09
//
//  Created by Shehab, Mohamed on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class ContactsViewController: UIViewController {

    var forumList = [Forum]()
    var newForum: Forum?
    var forumSelected: Int?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutClicked: UIBarButtonItem!
    
    @IBAction func logOffClicked(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
        }catch let signOutError as NSError {
            print("Error: ", signOutError)
        }
        
        AppDelegate.showLogin()
   
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewdidLoad in contactsviewcontroller")
        
        // Do any additional setup after loading the view.
        
        let rootRef = Database.database().reference()
        
//        //create an array of contacts
//        for i in 0...5 {
//
//            rootRef.child("contacts").childByAutoId().setValue(["name": "jeff xiong\(i)","email": "jeffxiong@uncc.edu", "phoneNumber": "704-555-5555", "phoneType": "Cell"])
//            //print(rootRef.child("contacts").childByAutoId().description())
//        }
        
        //register custom cell
        let cellNIb = UINib(nibName: "MyCustomTableViewCell", bundle: nil)
        tableView.register(cellNIb, forCellReuseIdentifier: "newCell")
        
        rootRef.child("forums").observe(.value, with: { (snapshot) in
            
            if snapshot.value != nil {

                self.forumList.removeAll()
                
                print("for loop raan")
                
                for child in snapshot.children {
                    
                    let forum = Forum()
                    let childSnapshot = child as! DataSnapshot
                    
                    if childSnapshot.hasChild("name") {
                        forum.name = childSnapshot.childSnapshot(forPath: "name").value as! String
                    }
                    if childSnapshot.hasChild("text") {
                        forum.text = childSnapshot.childSnapshot(forPath: "text").value as! String
                    }
                    if childSnapshot.hasChild("userId") {
                        forum.userID = childSnapshot.childSnapshot(forPath: "userId").value as! String
                    }
                    if childSnapshot.hasChild("likes") {
                        // get Dictionary of likes
                        let likesDict = childSnapshot.childSnapshot(forPath: "likes").value as! [String: Bool]
                        // convert Dictionary to Array of userID
                        forum.likes = Array(likesDict.keys)
                    }
                    forum.key = childSnapshot.key
                    self.forumList.append(forum)
                    
                }
                
                print("********** \(self.forumList.count)")
                self.tableView.reloadData()
                
            }
            else {
                
                print("The else Statement ran")
                
            }
            
        })
        
        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        //logout user in firebase first
        //then go to the login screen
        AppDelegate.showLogin()
    }
    
    //prepare to send object forum selected to forum
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ForumsToForum" {
            
            let destinationProfile = segue.destination as! DetailsViewController
            destinationProfile.selectedForum = forumList[forumSelected!]
            
            print("segue ran to form Forums to forum screen")
            
        }
    }
}

extension ContactsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return forumList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! MyCustomTableViewCell
        let forum = forumList[indexPath.row]
        let currentUserID = Auth.auth().currentUser?.uid

        //set labels with data
        cell.nameLabel.text = forum.name
        cell.descriptionLabel.text = forum.text
        cell.likeLabel.text = "\(forum.likes.count) Likes"
        
        // hides delete button if forum does not belong to current user
        if forum.userID != currentUserID {
            cell.trashImage.isHidden = true
        }
        
        // set image to "liked" if current user liked it
        if forum.likes.contains(currentUserID!) {
            cell.heartImage.setImage(UIImage(named: "like_favorite.png"), for: .normal)
        }
        
        cell.delegate = self

        return cell

    }



}


extension ContactsViewController: UITableViewDelegate {
    
    //determind with row was selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This row \(indexPath.row) is selected with Name of \(forumList[indexPath.row].name)")

        forumSelected = indexPath.row

        //performSegue
        performSegue(withIdentifier: "ForumsToForum", sender:  self)
        
    }
    
}


//interface
extension ContactsViewController: CustomTVCellDelegate {

    
    func delete(cell: UITableViewCell) {
        
        // create alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
            
            //delete cell
            let indexPath = self.tableView.indexPath(for: cell)
            
            print("this is the indexpath \(indexPath!)")
            
            let rootRef = Database.database().reference()
            
            print(self.forumList[indexPath![1]].key)
            rootRef.child("forums/\(self.forumList[indexPath![1]].key)").setValue(nil)
            
            self.tableView.reloadData()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func like(cell: UITableViewCell) {
        
        let indexPath = self.tableView.indexPath(for: cell)
        
        print("this is the indexpath \(indexPath!)")
        
        let userID = Auth.auth().currentUser?.uid
        
        print(forumList[indexPath![1]].key)
        
        let forum = forumList[indexPath![1]]
        
        // cannot like if user already liked it
        if !(forum.likes.contains(userID!)) {
            
            // like forum
            let rootRef = Database.database().reference()
            
            forum.likes.append(userID!)
            
            rootRef.child("forums/\(forum.key)/likes/\(userID!)").setValue(true)
        }
    }
        
        
}
    

