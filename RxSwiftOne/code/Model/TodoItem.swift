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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(isFinished, forKey: "isFinished")
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        isFinished = aDecoder.decodeBool(forKey: "isFinished")
        
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    init(name: String, isFinished: Bool) {
        self.name = name
        self.isFinished = isFinished
    }
    
    func toggleFinished()
    {
        isFinished = !isFinished
    }
}


