//
//  FirstViewController.swift
//  Tredou0.1
//
//  Created by 许鹏翔 on 15/9/5.
//  Copyright (c) 2015年 bestimever. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var parentId = 0
    var idToScroll: Int!
    
    //用于导航跳转的数组
    var navList = [[String:NSObject]]()
    
    //列出当前view所需要展示的所有row数据
    var listForParentId :[[String: NSObject]]{
        return ListData.sharedData.listForVCWithPid(parentId)
    }
    
    //关于键盘展开状态及键盘高度
    var keyboardShowUp = false {
        didSet{
            if keyboardShowUp {
                self.navigationItem.leftBarButtonItem?.enabled = false
                self.navigationItem.rightBarButtonItem?.enabled = false
                self.myCollectionView.userInteractionEnabled = false
            }else{
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.myCollectionView.userInteractionEnabled = true


            }
        }
    }
    var currentKeyboardHeight : CGFloat = 0
    
    //用于累计存储contentinset的变化量，然后在结束编辑后对view进行复原
    var moveDistance : CGFloat = 0

    @IBOutlet weak var myCollectionView: MyCollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addList(sender: UIBarButtonItem) {
        
        ListData.sharedData.addItem(parentId, text: "")
        
        
        //直接在数据源中添加新的空语句，再reloaddata。是否有更好的做法？
        let indexPath = NSIndexPath(forRow: listForParentId.count-1, inSection: 0)
        
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ListCell
        cell.textView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // CollectionView相关的设置
        myCollectionView.dataSource = self
        myCollectionView.delegate = self

        if parentId > 0{
            self.tableView.contentInset.top += 30
        }else{
            self.myCollectionView.hidden = true
        }

        
        //设置navlist的数据
        ListData.sharedData.parentForpid(parentId, navList: &navList)
        navList = Array(navList.reverse())
        

        
    }
    
    override func viewDidAppear(animated: Bool) {
    //导航条自动滑行
        if navList.count > 0 {
            myCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: navList.count-1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
        }
        
        if idToScroll != nil{
            var rowNum: Int = 0
            for index in 0..<listForParentId.count{
                if listForParentId[index]["id"] == idToScroll{
                    rowNum = index
                }
            }
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: rowNum, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    

    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAll"{
            if let newVC = segue.destinationViewController as? ShowAllChildItemsViewController{
                newVC.pid = self.parentId
                self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
            }
        }
    }

}

extension FirstViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listForParentId.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listcell", forIndexPath: indexPath) as! ListCell
        
        //设置代理
        cell.textView.delegate = self
        
        cell.bridgeDelegate = self

        //数据读取、设置文字和状态图
        let item = listForParentId[indexPath.row]
        cell.textView.text = item["text"] as! String
        cell.haveChildList = ListData.sharedData.haveChildList(item)
//        cell.stateImage.removeFromSuperview()
//        cell.textViewToLeftEdge.constant = 0
        
        return cell
    }
    
    //编辑和删除
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //如果键盘弹出了，不允许滑动删除
        if keyboardShowUp {
            return false
        }else{
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            // mark：数据删除
            let item = listForParentId[indexPath.row]
            let id = item["id"] as! Int
            ListData.sharedData.findAllChildItems(id)
            ListData.sharedData.deleteItems(&ListData.sharedData.itemsToDelete)
            print("\(ListData.sharedData.allData.count)")
            tableView.reloadData()
        }
    }
}

extension FirstViewController: UITextViewDelegate {
    
    //点击done，收起键盘。
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        let cell = textView.superview?.superview as! ListCell
        let size = textView.bounds.size
        let point = cell.convertPoint(textView.frame.origin, toView: self.view)
        
        //当键盘挡住row就把y轴坐标提高
        if((self.view.frame.size.height  - currentKeyboardHeight ) < (point.y + size.height)){
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, currentKeyboardHeight, 0.0)
            tableView.contentInset = contentInsets
            
            var aRect = self.view.frame
            aRect.size.height -= currentKeyboardHeight
            
//            if !CGRectContainsPoint(aRect, textView.frame.origin){
//                tableView.scrollRectToVisible(textView.frame, animated: true)
//            }
            if !CGRectContainsPoint(aRect, CGPointMake(point.x, point.y + size.height)){
                let activeRect = cell.convertRect(textView.frame, toView: self.view)
                tableView.scrollRectToVisible(activeRect, animated: true)
            }
        }
        
        
       }
    
    func textViewDidChange(textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        if size.height != newSize.height {
            
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            
            let cell = textView.superview?.superview as! ListCell
            let point = cell.convertPoint(textView.frame.origin, toView:self.view )
            
            if  ((self.view.frame.size.height  - currentKeyboardHeight ) < (point.y + newSize.height)){
                
                let distance = newSize.height - size.height
                
                tableView.contentInset.top -= distance
            }
        }
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        
        let cell = textView.superview?.superview as! ListCell
        if let indexPath = tableView.indexPathForRowAtPoint(cell.center){
            
            //存储数据
            if !textView.text.isEmpty {
                var item = listForParentId[indexPath.row]
                item.updateValue(textView.text, forKey: "text")
                ListData.sharedData.editItem(item)
            }
        }
    }
}


//获取keyboard的高度
extension FirstViewController {
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(sender: NSNotification){
        if let userInfo = sender.userInfo{
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height{
                currentKeyboardHeight = keyboardHeight

            }
        }
        keyboardShowUp = true
    }
    
    func keyboardWillHide(sender: NSNotification){
        keyboardShowUp = false
        currentKeyboardHeight = 0
        if parentId == 0{
            tableView.contentInset = UIEdgeInsetsMake(64, 0.0, 0.0, 0.0)
        }else{
            tableView.contentInset = UIEdgeInsetsMake(94, 0.0, 0.0, 0.0)
        }
    }
}


//跳转到新的界面
extension FirstViewController: Bridge{
    func showNewVCAtIndexPath(indexPath: NSIndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewControllerWithIdentifier("basic") as! FirstViewController
        newVC.navigationItem.setHidesBackButton(true, animated: false)
        
        let item = listForParentId[indexPath.row]
        let pid = item["id"] as! Int
        newVC.parentId = pid
        
        let navCon = self.navigationController! as UINavigationController
        navCon.popViewControllerAnimated(false)
        navCon.pushViewController(newVC, animated: false)
        
    }
}

//顶部导航相关
extension FirstViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return navList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CVCell", forIndexPath: indexPath) as! MyCollectionViewCell
        
        cell.cvCellDelegate = self
        let item = navList[indexPath.row]
        let navtext = item["text"] as! String
        cell.parentNavLabel.text = navtext
        
        return cell
    }
}

extension FirstViewController: CollectionBridge{
    
    //根据collectionview被点击的item推算出pid，再跳转到新的界面。
    func showParentVCAtIndexPath(indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewControllerWithIdentifier("basic") as! FirstViewController
        newVC.navigationItem.setHidesBackButton(true, animated: false)

        let navItem = navList[indexPath.row]
        let pid = navItem["pid"] as! Int
        newVC.parentId = pid
        
        let navCon = self.navigationController! as UINavigationController
        navCon.popViewControllerAnimated(false)
        navCon.pushViewController(newVC, animated: false)
        
        
        
    }
}
































