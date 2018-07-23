//
//  TaskDetailModel.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/13.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation

protocol TaskDetailModelDelegate: class {
    func listDidChange()
    func errorDidOccur(error: Error)
}

class TaskDetailModel {
    
    var theTask: Task?
    var projectList = [Project]()
    var taskManager = TaskManager()
    var reminderManager = ReminderManager()
    
    // Page Status
    var pageTitle = "Add Task"
    var isNewTask: Bool
    
    // Delegate
    weak var delegate: TaskDetailModelDelegate?
    
    init() {
        theTask = Task()
        isNewTask = true
        self.pageTitle = "Add Task"
    }
    
    init(projects: [Project]) {
        theTask = Task()
        self.projectList = projects
        isNewTask = true
        self.pageTitle = "Add Task"
    }
    
    init(task: Task, projects: [Project]) {
        theTask = task
        self.projectList = projects
        isNewTask = false
        self.pageTitle = "Edit Task"
    }
    
    // create NewTask
    func newTask(formTaskName: String, formNote: String, formDueDate: Date, formHowRepeat: String,
                 formPriority: String, formProject: Project?) {
        
        theTask?.taskName = formTaskName
        theTask?.note = formNote
        theTask?.dueDate = formDueDate
        theTask?.howRepeat = howRepeatStringToInt(howRepeatText: formHowRepeat)
        theTask?.priority = priorityStringToInt(priorityText: formPriority)
        theTask?.projectID = (formProject?.projectID)!
        self.taskManager.add(task: self.theTask!)
    }
    
    // edit Task
    func editTask(formTaskName: String, formNote: String, formDueDate: Date, formHowRepeat: String,
                  formPriority: String, formProject: Project?) {
        
        theTask?.taskName = formTaskName
        theTask?.note = formNote
        theTask?.dueDate = formDueDate
        theTask?.howRepeat = howRepeatStringToInt(howRepeatText: formHowRepeat)
        theTask?.priority = priorityStringToInt(priorityText: formPriority)
        theTask?.projectID = (formProject?.projectID)!
        self.taskManager.edit(task: self.theTask!)
        
    }
    
    
    // convert howRepeatText to Integer
    func howRepeatStringToInt(howRepeatText: String)-> Int {
        var howRepeat: Int!
        
        switch howRepeatText {
        case "毎月":
            howRepeat = 0
        case "毎週":
            howRepeat = 1
        case "毎日":
            howRepeat = 2
        case "なし":
            howRepeat = 3
        default:
            howRepeat = 3
        }
        
        return howRepeat
    }
    
    // convert priorityText to Integer
    func priorityStringToInt(priorityText: String)-> Int {
        var priority: Int!
        
        switch priorityText {
        case "High":
            priority = 0
        case "Middle":
            priority = 1
        case "Low":
            priority = 2
        default:
            priority = 1
        }
        
        return priority
    }
    
}
