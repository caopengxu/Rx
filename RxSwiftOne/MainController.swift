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
    
    var todoItems = Variable<[TodoItem]>([])
    let bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTodo: UIBarButtonItem!
    @IBOutlet weak var clearTodoBtn: UIButton!

    
    // storyboard
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        loadTodoItems()
    }
    
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoItems.asObservable().subscribe(onNext: { [weak self] todos in
            self?.updateUI(todos: todos)
        }).disposed(by: bag)
    }
    
    
    // 更新UI
    func updateUI(todos: [TodoItem])
    {
        clearTodoBtn.isEnabled = !todos.isEmpty
        addTodo.isEnabled = todos.filter { !$0.isFinished }.count < 5
        title = todos.isEmpty ? "Todo" : "\(todos.count) Todos"
        
        tableView.reloadData()
    }
    
    
    // 点击加号按钮
    @IBAction func addTodoItem(_ sender: Any)
    {
        let todoItem = TodoItem(name: "Todo Demo", isFinished: false)
        todoItems.value.append(todoItem)
    }
    
    
    // 点击删除按钮
    @IBAction func clearTodoList(_ sender: Any)
    {
        todoItems.value.removeAll()
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
            todoItems.value = unarchiver.decodeObject(forKey: "TodoItems") as! [TodoItem]
            
            unarchiver.finishDecoding()
        }
    }
    
    
    // 保存
    func saveTodoItems()
    {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiver.encode(todoItems.value, forKey: "TodoItems")
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
            let todo = todoItems.value[indexPath.row]
            todo.toggleFinished()
            
            todoItems.value[indexPath.row] = todo
            
            configureStatus(for: cell, with: todo)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        todoItems.value.remove(at: indexPath.row)
    }
}
extension MainController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems.value.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItem", for: indexPath)
        
        let todo = todoItems.value[indexPath.row]
        configureLabel(for: cell, with: todo)
        configureStatus(for: cell, with: todo)
        
        return cell
    }
}


