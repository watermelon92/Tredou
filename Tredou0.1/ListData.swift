//
//  ListData.swift
//  Tredou0.1
//
//  Created by 许鹏翔 on 15/9/9.
//  Copyright (c) 2015年 bestimever. All rights reserved.
//

import Foundation

class ListData: NSObject, NSCoding {
    
    private static let sharedInstance = ListData()
    
    class var sharedData : ListData {
        return sharedInstance
    }
        
    var allData: [[String: NSObject]] = [["id":1,"pid":0,"text":"从这里开始"],["id":2,"pid":1,"text":"二从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始"],["id":3,"pid":2,"text":"三从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始"],["id":4,"pid":3,"text":"四从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始"],["id":5,"pid":4,"text":"五从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始从这里开始"]]
    
    var id = 5
    
    var itemsToDelete = [[String: NSObject]]()
    
    var itemsToIndent = [[String: NSObject]]()
    
    struct PropertyKey {
        static let allDataKey = "allData"
        static let idKey = "id"
    }
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("ListData")
    
    override init(){
        super.init()
        print(ListData.ArchiveURL.path!)

        
        if (NSFileManager.defaultManager().fileExistsAtPath(ListData.ArchiveURL.path!)){
            loadData()
            }
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(allData, forKey: PropertyKey.allDataKey)
        aCoder.encodeInteger(id, forKey: PropertyKey.idKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        allData = aDecoder.decodeObjectForKey(PropertyKey.allDataKey) as! [[String: NSObject]]
        id = aDecoder.decodeIntegerForKey(PropertyKey.idKey)
        
    }
    
    func saveData(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        
        archiver.encodeObject(allData, forKey: PropertyKey.allDataKey)
        archiver.encodeInteger(id, forKey: PropertyKey.idKey)
        
        archiver.finishEncoding()
        
        let success = data.writeToFile( ListData.ArchiveURL.path!, atomically: true)
        if success{
            print("Success")
            }
    }
    
    func loadData(){
        if let data = NSData(contentsOfFile: ListData.ArchiveURL.path!){
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        
        allData = unarchiver.decodeObjectForKey(PropertyKey.allDataKey) as! [[String: NSObject]]
        id = unarchiver.decodeIntegerForKey(PropertyKey.idKey)
        
            unarchiver.finishDecoding()
        }
        
    }

    
    
    //读取数据
    func listForVCWithPid(pid:Int) -> [[String: NSObject]]{
        
        var array = [[String: NSObject]]()
        
        for item in allData{
            if (item["pid"] as! Int) == pid{
                array.append(item)
            }
        }
        
        return array
    }
    
    //新增数据
    func addItem(pid: Int,text: String){
        
        allData.append(["id":id+1,"pid":pid,"text":text])
        id += 1
        
        saveData()
        
    }

    //找到所有子节点,包括自己。
    func findAllChildItems(id:Int){
        for item in allData{
            if item["id"] == id{
                itemsToDelete.append(item)
            }
            if item["pid"] == id{
                itemsToDelete.append(item)
                findAllChildItems(item["id"] as! Int)
            }
        }
    }
    
    //删除所有子节点数据,包括自己。循环数组。
    func deleteItems(inout array:[[String:NSObject]]){
        for item in array{
            allData = allData.filter({$0 != item})
        }
        array =  [[String: NSObject]]()
        
        saveData()
    }

    
//    编辑数据
    func editItem(itemToEdit:[String: NSObject]){
        for index in 0..<allData.count{
            if allData[index]["id"] == itemToEdit["id"]{
                allData[index]["text"] = itemToEdit["text"]
            }
        }
        saveData()
    }
    
    //是否有子list
    func haveChildList(itemToLoad:[String: NSObject])-> Bool{
        for item in allData{
            if item["pid"] == itemToLoad["id"]{
                return true
            }
        }
        return false
    }
    
    //从父项一直遍历到祖先并形成数组，用于顶部导航
    func parentForpid(pid:Int,inout navList:[[String: NSObject]]) {
        for item in allData{
            if item["id"] == pid{
                navList.append(item)
                if item["pid"] != 0{
                    parentForpid(item["pid"] as! Int, navList: &navList)
                }
            }
        }

    }
    
    //找到所有子项目，用于透视图
    func findAllChildItems(id:Int,indentForChildItems indent:Int){
        for item in allData{
            if item["pid"] == id{
                var newItem = item
                newItem.updateValue(indent,forKey:"indent")
                itemsToIndent.append(newItem)
                findAllChildItems(item["id"] as! Int, indentForChildItems: indent + 1)
            }
        }
    }
    
    
    
    
}






























