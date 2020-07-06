//
//  ViewControllerPassword.swift
//  InClass_03
//
//  Created by Xiong, Jeff on 1/30/19.
//  Copyright © 2019 Xiong, Jeff. All rights reserved.
//

import UIKit

class ViewControllerPassword: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    @IBOutlet weak var updatedPasswordTextField: UITextField!
    
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navUpdateClicked(_ sender: Any) {
        if self.updatedPasswordTextField.text == ""{
            let alert = UIAlertController(title: "Error", message: "Please Enter All Infomation", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let passedData = ["password", updatedPasswordTextField.text!]
            NotificationCenter.default.post(name: NSNotification.Name("dataNotification"), object: passedData)
            navigationController?.popViewController(animated: true)
        }
    }
    
}
