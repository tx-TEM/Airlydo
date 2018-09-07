//
//  TaskDetailModel.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/06/13.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation

class TaskDetailModel {
    
    var theTask: Task
    var projectManager = ProjectManager.default
    
    // Page Status
    var pageTitle: String
    
    init(defaultProjectPath: String) {
        theTask = Task()
        theTask.projectPath = defaultProjectPath
        self.pageTitle = "Add Task"
    }
    
    init(task: Task) {
        theTask = task  //document ID has been setted
        self.pageTitle = "Edit Task"
    }
    
    
    // save
    func saveTask(formTaskName: String, formNote: String, formDueDate: Date,
                  formReminderList: [Date],formHowRepeat: String, formPriority: String, formProjectPath: String) {
        
        // dueDate -> 11:59:59
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: formDueDate)
        components.hour = 11
        components.minute = 59
        components.second = 59
        
        let oldProjectPath = theTask.projectPath
        
        theTask.taskName = formTaskName
        theTask.note = formNote
        theTask.dueDate = calendar.date(from: components)!
        theTask.reminderList = self.getUniqueReminder(reminderList: formReminderList)
        theTask.howRepeat = howRepeatStringToInt(howRepeatText: formHowRepeat)
        theTask.priority = priorityStringToInt(priorityText: formPriority)
        theTask.projectPath = formProjectPath
        
        theTask.saveData() { success in
            if(success){
                
                // Project Changed?
                if (oldProjectPath != self.theTask.projectPath && oldProjectPath != "") {
                    
                    // Delete theTask from oldProject
                    self.theTask.projectPath = oldProjectPath
                    self.theTask.delete()
                }
            }
        }
        
    }
    
    // Check ReminderList
    // Eliminate duplication and Sort
    private func getUniqueReminder(reminderList: [Date]) -> [Date] {
        var tempRemindList = [Date]()
        var uniqueRemindList = [Date]()
        
        // Reminder sec -> 0
        let calendar = Calendar.current
        
        for reminder in reminderList {
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder)
            tempRemindList.append(calendar.date(from: components)!)
        }
        
        // Eliminate duplication
        let orderedRemindList = NSOrderedSet(array: tempRemindList)
        uniqueRemindList = orderedRemindList.array as! [Date]

        return uniqueRemindList.sorted()
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
