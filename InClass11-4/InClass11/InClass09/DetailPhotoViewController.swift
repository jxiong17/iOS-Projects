//
//  DetailPhotoViewController.swift
//  InClass09
//
//  Created by Xiong, Jeff on 4/11/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class DetailPhotoViewController: UIViewController {
    
    
    @IBOutlet weak var detailImage: UIImageView!
    var selectedPhoto = Photo()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if selectedPhoto.photoURL != nil {
            let imageData = try! Data(contentsOf: selectedPhoto.photoURL!)
            detailImage?.image = UIImage(data: imageData)
        }
        
    }
    
    
    @IBAction func trashButtonClicked(_ sender: Any) {
        
        // create alert
        let alert = UIAlertController(title: "Photo Delete", message: "Do you want to delete this Photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in

            //deletion in Database
            let currentUserID = Auth.auth().currentUser?.uid

            let rootRef = Database.database().reference().child("users").child("\(currentUserID!)").child("photos")

            rootRef.child("\(self.selectedPhoto.key!)").setValue(nil)


            //delection in Storage
            //get the reference
            let storage = Storage.storage()

            // Create a root reference
            let storageRef = storage.reference()

            // Create a reference to the file to delete
            let desertRef = storageRef.child("\(String(describing: currentUserID!))/\(self.selectedPhoto.photoRefKey!)")
            print("Log: desertRef = \(String(describing: currentUserID!))/\(self.selectedPhoto.photoRefKey!)")

            // Delete the file
            desertRef.delete { error in
                if let error = error {
                    print("Log: The file was not deleted: \(error)")
                } else {
                    // File deleted successfully
                    print("Log:The file was successfully deleted")
                }
            }

            self.navigationController?.popToRootViewController(animated: true)


        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


}
