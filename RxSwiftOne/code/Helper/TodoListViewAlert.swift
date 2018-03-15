//
//  TodoListViewAlert.swift
//  RxSwiftOne
//
//  Created by caopengxu on 2018/3/7.
//  Copyright © 2018年 caopengxu. All rights reserved.
//

import UIKit

extension UIViewController
{
    typealias AlertCallback = ((UIAlertAction) -> Void)
    
    func flash(title: String, message: String, callback: AlertCallback? = nil)
    {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: callback
        )
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}


