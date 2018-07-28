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
    var projectDic = [String: Project]()

    var reminderManager = ReminderManager()
    
    // Page Status
    var pageTitle = "Add Task"
    
    // Delegate
    weak var delegate: TaskDetailModelDelegate?
    
    init() {
        theTask = Task()
        self.pageTitle = "Add Task"
    }
    
    init(projects: [Project], projectDic: [String:Project]) {
        theTask = Task()
        self.projectList = projects
        self.projectDic = projectDic
        self.pageTitle = "Add Task"
    }
    
    init(task: Task, projects: [Project], projectDic: [String:Project]) {
        theTask = task  //document ID has been setted
        self.projectList = projects
        self.projectDic = projectDic
        self.pageTitle = "Edit Task"
    }
    
    // save
    func saveTask(formTaskName: String, formNote: String, formDueDate: Date, formHowRepeat: String,
                 formPriority: String, formProjectPath: String) {
        
        // dueDate -> 11:59:59
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: formDueDate)
        components.hour = 11
        components.minute = 59
        components.second = 59
        
        theTask?.taskName = formTaskName
        theTask?.note = formNote
        theTask?.dueDate = calendar.date(from: components)!
        theTask?.howRepeat = howRepeatStringToInt(howRepeatText: formHowRepeat)
        theTask?.priority = priorityStringToInt(priorityText: formPriority)
        theTask?.projectPath = formProjectPath
        
        theTask?.saveData() { success in
            if(success){
                print("complete")
            }
        }
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
