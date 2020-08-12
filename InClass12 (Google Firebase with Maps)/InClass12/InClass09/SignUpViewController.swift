//
//  SignUpViewController.swift
//  InClass09
//
//  Created by Shehab, Mohamed on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        
        //confirm password
        if self.emailTextField.text == "" || self.nameTextField.text == "" || self.confirmPasswordTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please Enter All Infomation", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            //sign up the new user using Firebase
            Auth.auth().createUser(withEmail: emailTextField.text!, password: confirmPasswordTextField.text!) { (authResult, error) in
                
                if error == nil {
                    
                    print("Signup is successful")
                    
                    //                    let userID = Auth.auth().currentUser?.uid
                    //
                    //                    let rootRef = Database.database().reference()
                    //                    rootRef.child("users/\(userID!)").setValue(["name": self.nameTextfield.text!])
                    
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
        
        AppDelegate.showContacts()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        AppDelegate.showLogin()
    }
    
}
