//
//  TodoDetailController.swift
//  RxSwiftOne
//
//  Created by caopengxu on 2018/3/5.
//  Copyright © 2018年 caopengxu. All rights reserved.
//

import UIKit
import RxSwift

class TodoDetailController: UITableViewController {

    fileprivate let todoSubject = PublishSubject<TodoItem>()
    var todo: Observable<TodoItem> {
        return todoSubject.asObservable()
    }
    
    var todoItem: TodoItem!
    

    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isFinished: UISwitch!
    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    
    
    // 界面显示前后
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        todoName.becomeFirstResponder()
        if let todoItem = todoItem
        {
            todoName.text = todoItem.name
            isFinished.isOn = todoItem.isFinished
        }
        else
        {
            todoItem = TodoItem()
        }
        
        print("Resource tracing: \(RxSwift.Resources.total)")
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        todoSubject.onCompleted()
    }
    
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func cancel()
    {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func done()
    {
        todoItem.name = todoName.text!
        todoItem.isFinished = isFinished.isOn
        todoSubject.onNext(todoItem)
        
        dismiss(animated: true, completion: nil)
    }
}


extension TodoDetailController
{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44;
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        return nil
    }
}


extension TodoDetailController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarBtn.isEnabled = newText.length > 0
        
        return true
    }
}


