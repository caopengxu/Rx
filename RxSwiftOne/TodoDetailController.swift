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
    
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isFinished: UISwitch!
    @IBOutlet weak var doneBarBtn: UIBarButtonItem!

    fileprivate let todoSubject = PublishSubject<TodoItem>()
    var todo: Observable<TodoItem> {
        return todoSubject.asObservable()
    }
    var todoItem: TodoItem!
    
    fileprivate var todoCollage: UIImage?
    @IBOutlet weak var memoCollageBtn: UIButton!
    fileprivate let images = Variable<[UIImage]>([])
    var bag = DisposeBag()
    
    
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
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        todoName.becomeFirstResponder()
        
        // 订阅自身的Variable
        images.asObservable().subscribe(
            onNext: {[weak self] images in
                guard let `self` = self else {return}
                guard !images.isEmpty else
                {
                    self.resetMemoBtn()
                    return
                }
                
                self.todoCollage = UIImage.collage(images: images, in: self.memoCollageBtn.frame.size)
                self.setMemoBtn(bkImage: self.todoCollage ?? UIImage())
            }
        ).disposed(by: bag)
        
        // 根据模型设置界面
        if let todoItem = todoItem
        {
            todoName.text = todoItem.name
            isFinished.isOn = todoItem.isFinished
            doneBarBtn.isEnabled = true
            
            if todoItem.pictureMemoFilename != ""
            {
                let url = getDocumentsDir().appendingPathComponent(todoItem.pictureMemoFilename)
                
                if let data = try? Data(contentsOf: url)
                {
                    self.memoCollageBtn.setBackgroundImage(UIImage(data: data), for: .normal)
                    self.memoCollageBtn.setTitle("", for: .normal)
                }
            }
        }
        else
        {
            todoItem = TodoItem()
        }
    }
    
    // prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoCollectionController = segue.destination as! PhotoCollectionController
        images.value.removeAll()
        resetMemoBtn()
        
        let selectedPhotos = photoCollectionController.selectedPhotos.share()
        
        selectedPhotos.scan([]){(photos: [UIImage], newPhoto: UIImage) in
            
            var newPhotos = photos
            if let index = newPhotos.index(where: {UIImage.isEqual(lhs: newPhoto, rhs: $0)})
            {
                newPhotos.remove(at: index)
            }
            else
            {
                newPhotos.append(newPhoto)
            }
            
            return newPhotos
        }.subscribe(onNext: { images in
                self.images.value = images
        },onDisposed: {
            print("Finished choosing photo memos.")
        }).disposed(by: photoCollectionController.bag)
        
        
        selectedPhotos.ignoreElements().subscribe({ image in
            self.setMemoSectionHeaderText()
        }).disposed(by: photoCollectionController.bag)
    }
    
    // 点击取消按钮
    @IBAction func cancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    // 点击完成按钮
    @IBAction func done()
    {
        todoItem.name = todoName.text!
        todoItem.isFinished = isFinished.isOn
        todoItem.pictureMemoFilename = savePictureMemos()
        
        todoSubject.onNext(todoItem)
        todoSubject.onCompleted()
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: === 对图片的处理
extension TodoDetailController
{
    fileprivate func getDocumentsDir() -> URL
    {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
    }
    
    fileprivate func resetMemoBtn()
    {
        memoCollageBtn.setBackgroundImage(nil, for: .normal)
        memoCollageBtn.setTitle("Tap here to add your picture memos.", for: .normal)
    }
    
    fileprivate func setMemoBtn(bkImage: UIImage)
    {
        memoCollageBtn.setBackgroundImage(bkImage, for: .normal)
        memoCollageBtn.setTitle("", for: .normal)
    }
    
    fileprivate func savePictureMemos() -> String
    {
        if let todoCollage = self.todoCollage,
            let data = UIImagePNGRepresentation(todoCollage)
        {
            let path = getDocumentsDir()
            let filename = self.todoName.text! + UUID().uuidString + ".png"
            let memoImageUrl = path.appendingPathComponent(filename)
            
            try? data.write(to: memoImageUrl)
            
            return filename
        }
        
        return self.todoItem.pictureMemoFilename
    }
}


// MARK: === tableView相关
extension TodoDetailController
{
    func setMemoSectionHeaderText()
    {
        guard !images.value.isEmpty,
            let headerView = self.tableView.headerView(forSection: 2) else {return}
        
        headerView.textLabel?.text = "\(images.value.count) MEMOS"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section != 2
        {
            return 44
        }
        else
        {
            return 178
        }
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        return nil
    }
}


// MARK: === UITextFieldDelegate
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


