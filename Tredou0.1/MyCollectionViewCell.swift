//
//  MyCollectionViewCell.swift
//  Tredou0.1
//
//  Created by 许鹏翔 on 15/9/12.
//  Copyright (c) 2015年 bestimever. All rights reserved.
//

import UIKit

protocol CollectionBridge {
    func showParentVCAtIndexPath(indexPath: NSIndexPath)
}

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var parentNavLabel: UILabel!
    
    var cvCellDelegate: CollectionBridge?
    
    override func awakeFromNib() {
        let recognizer = UITapGestureRecognizer(target: self, action: "showParentList:")
        self.addGestureRecognizer(recognizer)
        
    }
    
    func showParentList(gesture: UITapGestureRecognizer){
        if let indexPath = collectionView?.indexPathForItemAtPoint(self.center){
            cvCellDelegate?.showParentVCAtIndexPath(indexPath)
        }
    }
    
}

extension MyCollectionViewCell{
    var collectionView: UICollectionView?{
        get{
            var collection: UIView? = superview
            while !(collection is UICollectionView) && collection != nil{
                collection = collection?.superview
            }
            return collection as? UICollectionView
        }
    }
}
