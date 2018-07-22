//
//  Reminder.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/22.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

// Reminder
class Reminder {
    var reminderID: String
    
    // Parent Task
    var taskID: String
    var taskName: String
    
    init() {
        reminderID = ""
        taskID = ""
        taskName = ""
    }
}
