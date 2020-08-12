//
//  ViewController.swift
//  InClass_03
//
//  Created by Xiong, Jeff on 1/30/19.
//  Copyright © 2019 Xiong, Jeff. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var departmentSelection: UISegmentedControl!
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mainToProfile" {
            
            let destinationProfile = segue.destination as! ViewControllerProfile
            let name = self.nameTextField.text
            let email = self.emailTextField.text
            let password = self.passwordTextField.text
            let department: String
            
            switch departmentSelection.selectedSegmentIndex {
            case 0:
                department = "CS"
            case 1:
                department = "SIS"
            case 2:
                department = "BIO"
            default:
                department = "Error"
            }
            
            destinationProfile.user = User(name!,email! , password!, department)
            
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "mainToProfile" {
            if self.nameTextField.text == "" || self.emailTextField.text == "" || self.passwordTextField.text == ""{
                let alert = UIAlertController(title: "Error", message: "Please Enter All Infomation", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            else{
                return true
            }
        }
        return true
    }
    
        
        
}

