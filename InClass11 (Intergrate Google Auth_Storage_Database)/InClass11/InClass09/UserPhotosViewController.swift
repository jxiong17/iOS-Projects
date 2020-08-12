//
//  UserPhotosViewController.swift
//  InClass09
//
//  Created by Xiong, Jeff on 4/11/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UserPhotosViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var CollectionView: UICollectionView!
    var photos = [Photo]()
    var numSections = 0
    var selectedPhoto = Photo()
    var placement = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/4 - 4, height: UIScreen.main.bounds.width/4 - 4)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        CollectionView!.collectionViewLayout = layout
        
        imagePicker.delegate = self
        
        //refRoot.setValue(["data": "\(data)"])
        let currentUserID = Auth.auth().currentUser!.uid
        let rootRef = Database.database().reference().child("users").child("\(currentUserID)").child("photos")
        rootRef.observe(.value, with: { (snapshot) in
            if snapshot.value != nil {
                
                self.photos.removeAll()
                self.placement = -1
                
                for child in snapshot.children {
                    let photo = Photo()
                    let photoRefID: String
                    let childSnapshot = child as! DataSnapshot
                    
                    self.placement += 1
                    photo.placement = self.placement
                    
                    if childSnapshot.hasChild("photoRefID") {
                        photoRefID = childSnapshot.childSnapshot(forPath: "photoRefID").value as! String
                        
                        // put URL into photo object and then append to array
                        
                        // Create a reference to the file you want to download
                        //get the reference
                        let storage = Storage.storage()
                        
                        // Create a root reference
                        let storageRef = storage.reference()
                        
                        let imageRef = storageRef.child("\(currentUserID)/\(photoRefID)")
                        
                        // Fetch the download URL
                        imageRef.downloadURL { url, error in
                            if let error = error {
                                // Handle any errors
                            } else {
                                // Get the download URL
                                photo.photoURL = url!
                                
                                // get photo key
                                photo.key = childSnapshot.key
                                
                                // get photo ref key
                                photo.photoRefKey = photoRefID
                                
                                // append to photos
                                self.photos.append(photo)
                                
                                if self.placement == self.photos.count-1 {
                                    self.sortPhotos()
                                    self.CollectionView.reloadData()
                                }
                                
                                
                            }
                        }
                        
                    }//end of if statment
                    
                    
                    
                }//end of for loop
                self.CollectionView.reloadData()
                
            } else {
                print("Log: Error in observe")
            }
            
        })
        
    }//end of view didLoad
    
    private func sortPhotos() {
        if photos.count < 2 {
            return
        }
        
        for photo in photos {
            print("photos before sorted: \(photo.placement)")
        }
        var loopAgain = true
        while (loopAgain) {
            loopAgain = false
            for i in 1..<photos.count {
                if photos[i].placement! < photos[i-1].placement! {
                    let temp = photos[i]
                    photos[i] = photos[i-1]
                    photos[i-1] = temp
                    for photo in photos {
                        print("photos after a sort: \(photo.placement)")
                    }
                    
                    loopAgain = true
                }
            }
        }
    }
    
    
    //add button
    @IBAction func addButtonClicked(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }//end of add button
    
    //prepare to send object forum selected to forum
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PhotosToDetails" {
            
            let destinationProfile = segue.destination as! DetailPhotoViewController
            destinationProfile.selectedPhoto = selectedPhoto
            
        }
    }//end of prepare
    
}//end of VC


extension UserPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            //get the reference
            let storage = Storage.storage()
            
            // Create a root reference
            let storageRef = storage.reference()
            
            let currentUserID = Auth.auth().currentUser!.uid
            
            let data = (image.jpegData(compressionQuality: 0.0))!
            
            // create photo ID
            let photoRefID = UUID().uuidString
            
            // Create a reference to 'images/mountains.jpg'
            let mountainImagesRef = storageRef.child("\(currentUserID)/\(photoRefID)")
            
            // Upload the file to Storage"
            let uploadTask = mountainImagesRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                self.CollectionView.reloadData()
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                mountainImagesRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    print("Log the image URL: \(downloadURL)")
                    //Upload to Database
                    let refRoot = Database.database().reference().child("users").child("\(currentUserID)").child("photos").childByAutoId()
                    refRoot.setValue(["photoRefID": photoRefID])
                    
                    self.CollectionView.reloadData()
                }
            }
            
            
            
            print("Log: photos count in imagePickerController: \(photos.count)")
            
            self.CollectionView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

//cell extension
extension UserPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    //set up columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4
    }
    
    //set up rows
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if photos.count%4 > 0 {
            numSections = photos.count/4 + 1
        } else {
            numSections = photos.count/4
        }
        return numSections
    }
    
    //set up cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath)
        
        let imagelabel = cell.viewWithTag(100) as? UIImageView
        
        let photoIndex = indexPath.row + (4 * indexPath.section)
        
        if photoIndex < photos.count {
            let imageUrl = photos[photoIndex].photoURL
            print("hello: \(imageUrl)")
            if imageUrl != nil {
                let imageData = try! Data(contentsOf: imageUrl!)
                imagelabel?.image = UIImage(data: imageData)
            }
        } else {
            imagelabel?.image = nil
        }
        
        return cell
    }
    
    //cell selections
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //selected photo
        print("This is the photo count in didSelect: \(photos.count)")
        print("This is the selected indexPath row: \(indexPath.row)")
        
        let photoIndex = indexPath.row + (4 * indexPath.section)
        
        if photoIndex < photos.count {
            selectedPhoto = photos[photoIndex]
            performSegue(withIdentifier: "PhotosToDetails", sender: self)
            print("Log: This is the cell selection at row:\(indexPath.row) and section: \(indexPath.section)")
            print("Log: This is the selected photo Key:\(selectedPhoto.key!)")
        }
    }
    
    
}
