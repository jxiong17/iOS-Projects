//
//  NewContactViewController.swift
//  InClass09
//
//  Created by Xiong, Jeff on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class NewContactViewController: UIViewController {
    
    
    @IBOutlet weak var textViewForum: UITextView!
    var userID: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textViewForum.layer.borderWidth = 1
        
        userID = Auth.auth().currentUser?.uid
        
        let rootRef = Database.database().reference()
        rootRef.child("users/\(userID!)").observe(.value, with: { (snapshot) in
            
            if snapshot.value != nil {
                
                if snapshot.hasChild("name") {
                    self.name = snapshot.childSnapshot(forPath: "name").value as! String
                }
                
            }
            else {
                
                print("The else Statement ran")
                
            }
            
        })

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        
        let rootRef = Database.database().reference()
        rootRef.child("forums").childByAutoId().setValue(["text": textViewForum.text, "userId": userID, "name": self.name])
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
//    //check empty textfields
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//
//
////        if self.nameTextField.text == "" || self.emailTextField.text == "" || self.phoneNumberTextField.text == ""{
////            let alert = UIAlertController(title: "Error", message: "Please Enter All Infomation", preferredStyle: .alert)
////            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
////            self.present(alert, animated: true, completion: nil)
////            return false
////        }
////        else{
////            return true
////        }
//    }
    
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        let destinationContacts = segue.destination as! ContactsViewController
//
//        destinationContacts.newContact = newContact
        
    }
    
    

}
