//
//  ReminderManager.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/21.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Firebase

class ReminderManager {
    
    // Firebase
    let db = Firestore.firestore()
    var reminderList = [Reminder]()
    
    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // get
    func getData(parentTask: Task) {
        
    }
    
    func getAllData() {
        
    }
    
    // add
    func add() {
        
    }
    
}
