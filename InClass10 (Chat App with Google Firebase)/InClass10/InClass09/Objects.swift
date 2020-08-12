//
//  Objects.swift
//  InClass09
//
//  Created by Xiong, Jeff on 3/27/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import Foundation


//creating a contact class
class Contact {
    
    var name:String
    var email:String
    var phoneNumber:String
    var phoneType:String
    var key: String
    
    
    init (_ name: String, _ email: String, _ phoneNumber: String, _ phoneType: String, _ key: String) {
        
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.phoneType = phoneType
        self.key = key
    }
    init() {
        
        self.name = ""
        self.email = ""
        self.phoneNumber = ""
        self.phoneType = ""
        self.key = ""
    }
    
}

class Forum {
    
    var name:String
    var text:String
    var userID:String
    var likes:[String]
    var key:String
    var comments = [Comment]()
    
    init() {
        
        self.name = ""
        self.text = ""
        self.userID = ""
        self.likes = []
        self.key = ""
        
    }
    
}

class Comment {
    
    var name: String
    var userID: String
    var key: String
    var comment: String
    
    init() {
        self.comment = ""
        self.userID = ""
        self.key = ""
        self.name = ""
    }
}
