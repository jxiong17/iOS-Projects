//
//  DetailsViewController.swift
//  InClass09
//
//  Created by Xiong, Jeff on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class DetailsViewController: UIViewController {
    
    var selectedForum: Forum?
    var commentText: String?
    @IBOutlet weak var tableView: UITableView!
    var currentUserName: String?
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.reloadData()
        let rootRef = Database.database().reference()
        //register 3 custom cell
        let cellNIb = UINib(nibName: "MyCustomTableViewCell", bundle: nil)
        tableView.register(cellNIb, forCellReuseIdentifier: "newCell")
        let cellNIb1 = UINib(nibName: "CommentBoxTableViewCell", bundle: nil)
        tableView.register(cellNIb1, forCellReuseIdentifier: "commentBoxCell")
        let cellNIb2 = UINib(nibName: "CommentDetailTableViewCell", bundle: nil)
        tableView.register(cellNIb2, forCellReuseIdentifier: "commentDetailCell")
        
        print("the selected forum name is: \(selectedForum!.name)")
        
        let userID = Auth.auth().currentUser?.uid
        rootRef.child("users/\(userID!)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if snapshot.value != nil {
                
                if snapshot.hasChild("name") {
                    self.currentUserName = snapshot.childSnapshot(forPath: "name").value as? String
                    print("The current user name is \(self.currentUserName!)")
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        //get the data from comments and add to forum object
        rootRef.child("forums/\(selectedForum!.key)/comments").observe(.value, with: { (snapshot) in
            
            if snapshot.value != nil {
                
                self.selectedForum?.comments.removeAll()
                
                //print("for loop raan")
                
                for child in snapshot.children {
                    
                    let comment = Comment()
                    let childSnapshot = child as! DataSnapshot
                    
                    if childSnapshot.hasChild("name") {
                        comment.name = childSnapshot.childSnapshot(forPath: "name").value as! String
                        //print(comment.name)
                    }
                    if childSnapshot.hasChild("comment") {
                        comment.comment = childSnapshot.childSnapshot(forPath: "comment").value as! String
                        //print(comment.comment)
                    }
                    if childSnapshot.hasChild("userID") {
                        comment.userID = childSnapshot.childSnapshot(forPath: "userID").value as! String
                        //print("The user id is: \(comment.userID)")
                    }
                    comment.key = childSnapshot.key
                    //print("The user id is: \(comment.key)")
                    self.selectedForum!.comments.append(comment)
                    
                }
                //print("this is the user id \(self.selectedForum!.comments[0].userID)")
                self.tableView.reloadData()
                
            }
            else {
                print("The else Statement ran")
            }
        })
        
    }
    
}

extension DetailsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedForum?.comments.count)! + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! MyCustomTableViewCell
            let currentUserID = Auth.auth().currentUser?.uid

            //set labels with data
            cell.nameLabel.text = selectedForum!.name
            cell.descriptionLabel.text = selectedForum!.text
            cell.likeLabel.text = "\(selectedForum!.likes.count) Likes"
            cell.trashImage.isHidden = true

            // set image to "liked" if current user liked it
            if selectedForum!.likes.contains(currentUserID!) {
                cell.heartImage.setImage(UIImage(named: "like_favorite.png"), for: .normal)
            }
            
            cell.delegate = self

            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentBoxCell", for: indexPath) as! CommentBoxTableViewCell

            cell.forumDelegate = self
  
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentDetailCell", for: indexPath) as! CommentDetailTableViewCell

            cell.commentLabel.text = selectedForum?.comments[indexPath.row - 2].comment
            cell.nameCommentLabel.text = selectedForum?.comments[indexPath.row - 2].name
            let currentUserID = Auth.auth().currentUser?.uid
            
            // hides delete button if forum does not belong to current user
            if selectedForum?.comments[indexPath.row - 2].userID != currentUserID {
                cell.commentTrashButton.isHidden = true
            }
            
            //call on delete button clicked function
            cell.forumDelegate = self
            
            return cell
       }
    }
}

extension DetailsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("seleted this cell: \(indexPath.row)")
        
        
    }
    
}


extension DetailsViewController: CustomTVCellDelgateForForumDetail {
    
    func delete(cell: UITableViewCell) {
        
        // create alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
            
            //delete cell
            let indexPath = self.tableView.indexPath(for: cell)
            
            print("this is the indexpath in comment cells \(indexPath!)")
            
            let rootRef = Database.database().reference()
            
            let cellpath = indexPath!.row - 2
            print("the cell path is: \(cellpath)")
            print("this is the key being deleted: \(self.selectedForum!.comments[cellpath].key)")
            rootRef.child("forums/\(self.selectedForum!.key)/comments/\(self.selectedForum!.comments[cellpath].key)").setValue(nil)
            
            self.tableView.reloadData()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension DetailsViewController: CustomTVCellDelgateForForumCommentBox {
    
    
    //this function is run when the user click on the submit
    //placed the string form the CommentBoxTableView class
    func submit(comment: String) {
       
        print("this is the comment: \(comment)")
            
        // comments under forum
        let rootRef = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
            
        rootRef.child("forums/\(selectedForum!.key)/comments").childByAutoId().setValue(["name":self.currentUserName, "userID": userID, "comment": comment])
  
    }
    
    
}

extension DetailsViewController: CustomTVCellDelegate {
    
    func like(cell: UITableViewCell) {
        
        let indexPath = self.tableView.indexPath(for: cell)
        
        print("this is the indexpath \(indexPath!)")
        
        let userID = Auth.auth().currentUser?.uid
        
        // cannot like if user already liked it
        if !(selectedForum!.likes.contains(userID!)) {
            
            // like forum
            let rootRef = Database.database().reference()
            
            selectedForum!.likes.append(userID!)
            
            rootRef.child("forums/\(selectedForum!.key)/likes/\(userID!)").setValue(true)
        }
        
        self.tableView.reloadData()
    }
    
    
}

