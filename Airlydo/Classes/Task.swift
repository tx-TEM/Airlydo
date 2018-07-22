//
//  Task.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation

// Task
class Task{
    var taskID: String
    var taskName: String
    var note: String
    var isArchive: Bool
    var dueDate: Date
    var howRepeat: Int  //0:毎月, 1:毎週, 2:毎日, 3:なし
    var priority: Int   //0:low, 1:middle, 2:high
    
    // Parent Project
    var projectID = ""
    
    init() {
        self.taskID = ""
        self.taskName = ""
        self.note = ""
        self.isArchive = false
        self.dueDate = Date()
        self.howRepeat = 3
        self.priority = 1
        self.projectID = ""
    }
    
    init(taskID: String, taskName: String, note: String, isArchive: Bool,
        dueDate: Date, howRepeat: Int, priority: Int, projectID: String) {
        
        self.taskID = taskID
        self.taskName = taskName
        self.note = note
        self.isArchive = isArchive
        self.dueDate = dueDate
        self.howRepeat = howRepeat
        self.priority = priority
        self.projectID = projectID
    }
    
}
