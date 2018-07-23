//
//  TaskManager.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class TaskManager {
    
    // Firebase
    let db = Firestore.firestore()
    
    var TaskList = [Task]()
    
    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // load Data from Project
    func loadData (isArchiveMode: Bool, projectID: String) {
       
    }
    
    // load All Data
    func loadAllData (isArchiveMode: Bool) {

    }
    
    func get(index: Int) -> Task {
        return TaskList[index]
    }
    
    
}
