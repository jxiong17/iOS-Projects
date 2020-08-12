//
//  CommentBoxTableViewCell.swift
//  InClass09
//
//  Created by Xiong, Jeff on 4/7/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit

protocol CustomTVCellDelgateForForumCommentBox {
    //pass the string instead the cell
    func submit(comment: String)
    
}

class CommentBoxTableViewCell: UITableViewCell {

    //create delegate
    var forumDelegate: CustomTVCellDelgateForForumCommentBox?
    
    @IBOutlet weak var commentTextField: UITextField!
    
    
    //if user click on the submit
    @IBAction func submitCommentClicked(_ sender: Any) {
        
        //check to see if box is empty before sending the data text
        if  !(self.commentTextField.text?.isEmpty)! {
            let commentText = self.commentTextField.text!
            forumDelegate?.submit(comment: commentText)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
