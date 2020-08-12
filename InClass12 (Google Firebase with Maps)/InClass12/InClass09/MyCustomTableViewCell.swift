//
//  MyCustomTableViewCell.swift
//  Homework_02
//
//  Created by Yang, Marvin on 2/19/19.
//  Copyright © 2019 Xiong, Jeff. All rights reserved.
//

import UIKit

protocol CustomTVCellDelegate {
    func delete(cell: UITableViewCell)
}

class MyCustomTableViewCell: UITableViewCell {
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var delegate: CustomTVCellDelegate?
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        delegate?.delete(cell: self)
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
