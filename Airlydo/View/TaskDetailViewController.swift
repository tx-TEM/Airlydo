//
//  AddTaskPageController.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/05/22.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//


import UIKit
import Eureka

class TaskDetailViewController: FormViewController {
    
    @IBOutlet weak var SaveTaskButton: UIBarButtonItem!
    
    var taskDetailModel: TaskDetailModel?
    
    var recvVal: String = ""
    var formProjectPath: String = ""
    
    @IBAction func SaveTaskButtonTapped(_ sender: UIButton) {
        let valuesDictionary = form.values()
        
        // Reminder
        let formReminderTags = [String](valuesDictionary.keys).filter({$0.contains("ReminderTag_")}).sorted()
        var formRemindList: [Date] = []
        
        for remTag in formReminderTags{
            let reminder = valuesDictionary[remTag] as? Date
            
            if let theReminder = reminder {
                formRemindList.append(theReminder)
            }
        }
        
        // Save Task
        CATransaction.begin()
        self.navigationController?.popViewController(animated: true)
        CATransaction.setCompletionBlock({
            
            self.taskDetailModel?.saveTask(formTaskName: valuesDictionary["TitleTag"] as! String,
                                           formNote: valuesDictionary["NoteTag"] as! String,
                                           formDueDate: valuesDictionary["DueDateTag"] as! Date,
                                           formReminderList: formRemindList,
                                           formHowRepeat: valuesDictionary["RepeatTag"] as! String,
                                           formPriority: valuesDictionary["PriorityTag"] as! String,
                                           formProjectPath: self.formProjectPath)
        })
        CATransaction.commit()
    }
    
    func updateNote(note: String){
        let noteForm:LabelRow = form.rowBy(tag:"NoteTag") as! LabelRow
        noteForm.value = note
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.taskDetailModel == nil {
            self.taskDetailModel = TaskDetailModel(defaultProjectPath: Project().projectPath)
        }
        
        guard  let taskDetailModel = self.taskDetailModel else {
            return
        }
        
        self.navigationItem.title = taskDetailModel.pageTitle
        
        form +++ Section("Task")
            <<< TextRow("TitleTag"){
                $0.title = "Add a Task"
                $0.value = taskDetailModel.theTask.taskName
            }
            <<< LabelRow("NoteTag"){
                $0.title = "Note"
                $0.value = taskDetailModel.theTask.note
                }.onCellSelection{ [weak self] cell, row in
                    
                    guard let `self` = self else {
                        return
                    }
                    
                    let SetNotePageController = self.storyboard?.instantiateViewController(withIdentifier: "SetNotePageController") as! SetNotePageController
                    SetNotePageController.noteValue = row.value
                    self.navigationController?.pushViewController(SetNotePageController, animated: true)
            }
            
            <<< LabelRow("ProjectTag"){
                $0.title = "Project"
                let projPath = taskDetailModel.theTask.projectPath
                
                if projPath != "" {
                    $0.value = taskDetailModel.projectManager.getProjectDic[projPath]?.projectName
                    formProjectPath = projPath
                }else{
                    $0.value = "InBox"
                    formProjectPath = Project().projectPath
                }
                
                
                }.onCellSelection{ [weak self] cell, row in
                    
                    guard let `self` = self else {
                        return
                    }
                    
                    let controller = UIAlertController(title: "Project",
                                                       message: nil,
                                                       preferredStyle: .actionSheet)
                    
                    
                    // Add Action
                    let projectList = taskDetailModel.projectManager.getProjectList()
                    for data in projectList {
                        controller.addAction(UIAlertAction(title: data.projectName, style: .default, handler: {
                            (action: UIAlertAction!) -> Void in
                            
                            row.value = action.title!
                            self.formProjectPath = data.projectPath
                            row.updateCell()
                            
                        }))
                    }
                    
                    controller.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                    
                    self.present(controller, animated: true, completion: nil)
        }
        
        
        form +++ Section("")
            <<< DateRow("DueDateTag") {
                $0.title = "Due Date"
                $0.value = taskDetailModel.theTask.dueDate
                
            }
            
            <<< ActionSheetRow<String>("RepeatTag") {
                $0.title = "Repeat"
                
                $0.selectorTitle = "繰り返し"
                var repeatArray = ["毎月","毎週","毎日", "なし"]
                $0.options = repeatArray
                
                $0.value = repeatArray[taskDetailModel.theTask.howRepeat]
                
        }
        
        
        
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],header: "Reminder") {
            $0.addButtonProvider = { section in
                return ButtonRow(){
                    $0.title = "Add"
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return DateTimeRow("NReminderTag_\(index+1)") {
                    $0.title = ""
                }
            }
            
            for (index, reminder) in self.taskDetailModel!.theTask.reminderList.enumerated() {
                $0 <<< DateTimeRow("ReminderTag_\(index+1)") {
                    $0.title = ""
                    $0.value = reminder
                }
            }
        }
        
        form +++ Section("Option")
            <<< ActionSheetRow<String>("PriorityTag") {
                var priorityArray = ["High","Middle","Low"]
                
                $0.title = "Priority"
                $0.selectorTitle = "set priority"
                $0.options = priorityArray
                $0.value = priorityArray[taskDetailModel.theTask.priority]
            }
            
            <<< LabelRow("AssignTag"){
                $0.title = "Assign"
                /*
                 if let assignName = taskDetailModel?.theTask?.assign?.assignName {
                 $0.value = assignName
                 }else{
                 $0.value = "自分"
                 }
                 
                 }.onCellSelection{ cell, row in
                 
                 let controller = UIAlertController(title: "Assign",
                 message: nil,
                 preferredStyle: .actionSheet)
                 
                 // Add Button
                 controller.addAction(UIAlertAction(title: "自分", style: .default, handler:{
                 (action: UIAlertAction!) -> Void in
                 row.value = action.title!
                 self.formAssign = nil
                 row.updateCell()
                 }))
                 
                 if let assignList = self.taskDetailModel?.assignList {
                 
                 for data in assignList{
                 controller.addAction(UIAlertAction(title: data.assignName, style: .default, handler: {
                 (action: UIAlertAction!) -> Void in
                 
                 row.value = action.title!
                 self.formAssign = data
                 row.updateCell()
                 
                 }))
                 }
                 }
                 
                 controller.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                 
                 self.present(controller, animated: true, completion: nil)
                 */
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

