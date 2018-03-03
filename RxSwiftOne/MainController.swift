//
//  MainController.swift
//  RxSwiftOne
//
//  Created by caopengxu on 2018/3/3.
//  Copyright © 2018年 caopengxu. All rights reserved.
//

import UIKit
import RxSwift

let Cell_CheckMark_Tag = 1001
let Cell_Todo_title_tag = 1002


class MainController: UIViewController {
    
    var todoItems: [TodoItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTodo: UIBarButtonItem!
    @IBOutlet weak var clearTodoBtn: UIButton!

    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTodoItems()
    }
    
    
    // 点击加号按钮
    @IBAction func addTodoItem(_ sender: Any)
    {
        let newRowIndex = todoItems.count
        
        let todoItem = TodoItem(name: "Todo Demo", isFinished: false)
        todoItems.append(todoItem)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    
    // 点击删除按钮
    @IBAction func clearTodoList(_ sender: Any)
    {
        todoItems = [TodoItem]()
        tableView.reloadData()
    }
    
    
    // 点击保存按钮
    @IBAction func saveTodoList(_ sender: Any)
    {
        saveTodoItems()
    }
}


// MARK: === 方法
extension MainController
{
    // 创建plist
    func loadTodoItems()
    {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path)
        {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            todoItems = unarchiver.decodeObject(forKey: "TodoItems") as! [TodoItem]
            
            unarchiver.finishDecoding()
        }
    }
    
    
    // 保存
    func saveTodoItems()
    {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiver.encode(todoItems, forKey: "TodoItems")
        archiver.finishEncoding()
        
        data.write(to: dataFilePath(), atomically: true)
    }
    
    
    // plist路径
    func dataFilePath() -> URL
    {
        return documentsDirectory().appendingPathComponent("TodoList.plist")
    }
    func documentsDirectory() -> URL
    {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    
    // 修改cell状态
    func configureStatus(for cell: UITableViewCell, with item: TodoItem)
    {
        let label = cell.viewWithTag(Cell_CheckMark_Tag) as! UILabel
        
        if item.isFinished
        {
            label.text = "✓"
        }
        else
        {
            label.text = ""
        }
    }
    
    
    // 修改cell文字内容
    func configureLabel(for cell: UITableViewCell, with item: TodoItem)
    {
        let label = cell.viewWithTag(Cell_Todo_title_tag) as! UILabel
        label.text = item.name
    }
}


// MARK: === UITableViewDelegate、UITableViewDataSource
extension MainController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath)
        {
            let todo = todoItems[indexPath.row]
            
            todo.toggleFinished()
            configureStatus(for: cell, with: todo)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        todoItems.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
}
extension MainController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItem", for: indexPath)
        
        let todo = todoItems[indexPath.row]
        configureLabel(for: cell, with: todo)
        configureStatus(for: cell, with: todo)
        
        return cell
    }
}


