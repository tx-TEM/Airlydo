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
    
    
    // load Reminder from cloud
    func loadData(parentTask: Task ,completed: @escaping () -> ()) {
        db.collection(parentTask.projectPath + "/Task" + parentTask.taskID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    // get
    func get(index: Int) -> Reminder {
        return reminderList[index]
    }
    
    func getAllData() -> [Reminder] {
        return reminderList
    }
    
    // add
    func add(parentTask: Task) {
        
    }
    
    // delete
    func delete(parentTask: Task, reminderID: String) {
        
    }
    
}
