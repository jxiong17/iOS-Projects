//
//  CommentDetailTableViewCell.swift
//  InClass09
//
//  Created by Xiong, Jeff on 4/7/19.
//  Copyright © 2019 UNCC. All rights reserved.
//

import UIKit

protocol CustomTVCellDelgateForForumDetail {
    func delete(cell: UITableViewCell)
    
}

class CommentDetailTableViewCell: UITableViewCell {

    var forumDelegate: CustomTVCellDelgateForForumDetail?
    @IBOutlet weak var nameCommentLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTrashButton: UIButton!
    
    
    
    @IBAction func deleteCommentClicked(_ sender: Any) {
        forumDelegate?.delete(cell: self)
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
