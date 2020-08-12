//
//  ViewControllerDepartment.swift
//  InClass_03
//
//  Created by Xiong, Jeff on 1/30/19.
//  Copyright © 2019 Xiong, Jeff. All rights reserved.
//

import UIKit

class ViewControllerDepartment: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var updatedDepartmentSelection: UISegmentedControl!
   
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navUpdateClicked(_ sender: Any) {
        let updatedDepartment: String
        switch updatedDepartmentSelection.selectedSegmentIndex {
        case 0:
            updatedDepartment = "CS"
        case 1:
            updatedDepartment = "CS"
        case 2:
            updatedDepartment = "BIO"
        default:
            updatedDepartment = "Error"
        }
        
        let passedData = ["department", updatedDepartment]
        NotificationCenter.default.post(name: NSNotification.Name("dataNotification"), object: passedData)
        navigationController?.popViewController(animated: true)
    }
    
    
}
