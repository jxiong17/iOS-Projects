//
//  ViewControllerProfile.swift
//  InClass_03
//
//  Created by Xiong, Jeff on 1/30/19.
//  Copyright © 2019 Xiong, Jeff. All rights reserved.
//

import UIKit

class ViewControllerProfile: UIViewController {

    var user: User?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var showLabel: UIButton!
    var label = ""
    var updateEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameLabel.text = user!.name
        self.emailLabel.text = user!.email
        self.departmentLabel.text = user!.department
        
        
        print("The count of password \(self.user!.password.count)")
        
        label = ""
        for _ in 0..<self.user!.password.count {
            label += "*"
        }
        
        self.passwordLabel.text = label
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveData(notification:)), name: Notification.Name("dataNotification"), object: nil)
        
    }
    
    @objc func onReceiveData(notification: Notification) {
        
        var retrievedData = notification.object as! [String]
        
        switch retrievedData[0] {
        case "email":
            self.emailLabel.text = retrievedData[1]
        case "name":
            self.nameLabel.text = retrievedData[1]
        case "password":
            self.user?.password = retrievedData[1]
            label = ""
            for _ in 0..<self.user!.password.count {
                label += "*"
            }
            self.passwordLabel.text = label
        case "department":
            self.departmentLabel.text = retrievedData[1]
        default:
            print("Error")
        }
    }
    
    
    @IBAction func showButton(_ sender: Any) {
        
        if self.showLabel.titleLabel?.text == "Show" {
            
            self.passwordLabel.text = user!.password
            self.showLabel.setTitle("Hide", for: .normal)
        }
        else {
            self.passwordLabel.text = label
            self.showLabel.setTitle("Show", for: .normal)
        }
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
    
    
    
    
    
}



class User {
    
    var name:String
    var email:String
    var password:String
    var department:String
    
    init (_ name: String, _ email: String, _ password: String, _ department: String) {
        
        self.name = name
        self.email = email
        self.password = password
        self.department = department
    }
        
}
