//
//  LoginViewController.swift
//  InClass09
//
//  Created by Shehab, Mohamed on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (authResult, error) in
            
            if self.emailTextField.text == "" || self.passwordTextField.text == "" {
                let alert = UIAlertController(title: "Error", message: "Please Enter All Infomation", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            else{
                
                if error != nil {
                    print("Error in login")
                    let alert = UIAlertController(title: "Error", message: "Incorrect Email or Password", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else {
                    print("Signup is successful")
                    AppDelegate.showContacts()
                }
            }
            
        })
    }
    
    @IBAction func createAccountClicked(_ sender: Any) {
        AppDelegate.showSignUp()
    }
}
