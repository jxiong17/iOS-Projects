//
//  SignUpViewController.swift
//  InClass09
//
//  Created by Shehab, Mohamed on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        
    
        
        //confirm password
        if self.emailTextField.text == "" || self.nameTextField.text == "" || self.passwordTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please Enter All Infomation", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            //sign up the new user using Firebase
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
                
                if error == nil {
                    
                    print("Signup is successful")
                    
                    let userID = Auth.auth().currentUser?.uid
                    
                    let rootRef = Database.database().reference()
                    rootRef.child("users/\(userID!)").setValue(["name": self.nameTextField.text!])
                    
                    AppDelegate.showContacts()
                }
                else {
                    
                    print("Error: \(error.debugDescription)")
                    let alert = UIAlertController(title: "Error", message: "Password should be at least 6 characters long or invalid email", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
          
        }
    
        

        
        //when done successfully
        //go to the Contacts View Controller.
        
        
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        AppDelegate.showLogin()
    }
    

}
