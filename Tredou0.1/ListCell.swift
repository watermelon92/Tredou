//
//  ListCell.swift
//  Tredou0.1
//
//  Created by 许鹏翔 on 15/9/5.
//  Copyright (c) 2015年 bestimever. All rights reserved.
//

import UIKit

protocol Bridge {
    func showNewVCAtIndexPath(indexPath: NSIndexPath)
}

class ListCell: UITableViewCell {
    
    //桥接cell和viewcontroller，提供数据中转
    var bridgeDelegate : Bridge?
    
    @IBOutlet weak var textViewToLeftEdge: NSLayoutConstraint!
    //设置不同的状态图
    let emptyImage = UIImage(named: "Empty")
    let fullImage = UIImage(named: "Full")

    var haveChildList = false{
        didSet{
            if !haveChildList {
                stateImage.image = emptyImage
            }else{
                stateImage.image = fullImage
            }
        }
    }
    
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var stateImage: UIImageView!
    
    func showSubList(gesture: UITapGestureRecognizer){
        if let indexPath = tableView?.indexPathForCell(self){
            bridgeDelegate?.showNewVCAtIndexPath(indexPath)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.scrollEnabled = false
        
        //给stateImage添加点击手势
        let recognizer = UITapGestureRecognizer(target: self, action: "showSubList:")
        stateImage.addGestureRecognizer(recognizer)
        
//        textView.backgroundColor = UIColor.orangeColor()
        


    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

//在cell中引用tableview
extension ListCell {
    var tableView: UITableView?{
        get{
            var table: UIView? = superview
            while !(table is UITableView) && table != nil{
                table = table?.superview
            }
            return table as? UITableView
        }
    }
}
