//
//  IndentCellTableViewCell.swift
//  Tredou0.1
//
//  Created by 许鹏翔 on 15/9/18.
//  Copyright (c) 2015年 bestimever. All rights reserved.
//

import UIKit

class IndentCellTableViewCell: UITableViewCell {

    @IBOutlet weak var indentTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let indentation = CGFloat(self.indentationLevel)
        let indentPoints = indentationWidth * indentation
        
        self.contentView.frame = CGRectMake(indentPoints,self.contentView.frame.origin.y,self.contentView.frame.size.width - indentPoints,self.contentView.frame.height)
    }

}
