//
//  TodoItem.swift
//  RxSwiftOne
//
//  Created by caopengxu on 2018/3/3.
//  Copyright © 2018年 caopengxu. All rights reserved.
//

import UIKit

class TodoItem: NSObject, NSCoding {
    
    var name: String = ""
    var isFinished: Bool = false
    var pictureMemoFilename: String = ""
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(isFinished, forKey: "isFinished")
        aCoder.encode(pictureMemoFilename, forKey: "pictureMemoFilename")
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        isFinished = aDecoder.decodeBool(forKey: "isFinished")
        pictureMemoFilename = aDecoder.decodeObject(forKey: "pictureMemoFilename") as! String
        
        super.init()
    }
    
    override init() { super.init() }
    
    init(name: String, isFinished: Bool, pictureMemoFilename: String) {
        self.name = name
        self.isFinished = isFinished
        self.pictureMemoFilename = pictureMemoFilename
    }
    
    func toggleFinished()
    {
        isFinished = !isFinished
    }
}


