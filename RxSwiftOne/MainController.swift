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

enum SaveTodoError: Error {
    case cannotSaveToLocalFile
    case iCloudIsNotEnabled
    case cannotReadLocalFile
    case cannotCreateFileOnCloud
}


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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let naviController = segue.destination as! UINavigationController
        let currController = naviController.topViewController as! TodoDetailController
        
        if segue.identifier == "AddTodo"
        {
            currController.title = "Add Todo"
            
            _ = currController.todo.subscribe(
                onNext: {
                    [weak self] newTodo in
                    self?.todoItems.value.append(newTodo)
                },
                onDisposed: {
                    print("Finish adding a new todo.")
                }
            )
        }
        else if segue.identifier == "EditTodo"
        {
            currController.title = "Edit Todo"
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            {
                currController.todoItem = todoItems.value[indexPath.row]
                
                _ = currController.todo.subscribe(
                    
                    onNext: {
                        [weak self] todo in
                        self?.todoItems.value[indexPath.row] = todo
                    },
                    onDisposed: {
                        print("Finish editing a new todo.")
                }
                )
            }
        }
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
    
    
    // 同步到cloud
    @IBAction func syncCloud(_ sender: Any)
    {
        syncTodoToCloud()
    }
    
    
    // 点击保存按钮
    @IBAction func saveTodoList(_ sender: Any)
    {
        saveTodoItems()
    }
}


// MARK: === 扩展方法
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
    
    // 把保存在本地的Todo同步到iCloud
    func ubiquityURL(_ filename: String) -> URL?
    {
        let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        
        if ubiquityURL != nil
        {
            return ubiquityURL!.appendingPathComponent("filename")
        }
        
        return nil
    }
    func syncTodoToCloud()
    {
        guard let cloudUrl = ubiquityURL("Documents/TodoList.plist") else
        {
            self.flash(title: "Failed", message: "You should enabled iCloud in Settings first.")
            
            return
        }
        guard let localData = NSData(contentsOf: dataFilePath()) else
        {
            self.flash(title: "Failed", message: "Cannot read local file.")
            
            return
        }
        
        let plist = PlistDocument(fileURL: cloudUrl, data: localData)
        
        plist.save(to: cloudUrl, for: .forOverwriting, completionHandler: {
            (success: Bool) -> Void in
            print(cloudUrl)
            
            if success
            {
                self.flash(title: "Success", message: "All todos are synced to cloud.")
            }
            else
            {
                self.flash(title: "Failed", message: "Sync todos to cloud failed")
            }
        })
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44;
    }
}


