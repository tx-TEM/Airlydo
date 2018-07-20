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
    var taskID = ""
    var taskName = ""
    var note = ""
    var isArchive = false
    var dueDate = Date()
    var howRepeat = 3  //0:毎月, 1:毎週, 2:毎日, 3:なし
    var priority = 1   //0:low, 1:middle, 2:high
    
    // Parent Project
    var projectID: String?
    
    init() {
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
