//
//  TodoListViewAlert.swift
//  RxSwiftOne
//
//  Created by caopengxu on 2018/3/7.
//  Copyright © 2018年 caopengxu. All rights reserved.
//

import UIKit

extension MainController
{
    func flash(title: String, message: String)
    {
        let alerController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default
        )
        
        alerController.addAction(okAction)
        
        self.present(alerController, animated: true, completion: nil)
    }
}


