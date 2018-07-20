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
    
    // Read Data from Project
    func readData (isArchiveMode: Bool, projectID: String) {
       
    }
    
    // Read All Data
    func readAllData (isArchiveMode: Bool) {

    }
    
    func get(index: Int) -> Task {
        return TaskList[index]
    }
    

    // Add new Task
    
    func addTask(task: Task) {
        
        // dueDate -> 11:59:59
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: task.dueDate)
        components.hour = 11
        components.minute = 59
        components.second = 59
        
        var ref: DocumentReference? = nil
        ref = db.collection("User/user1/Project/" + task.projectID! + "/Task").addDocument(data: [
            "taskName": task.taskName,
            "note": task.note,
            "dueDate" : calendar.date(from: components)!,
            "howRepeat": task.howRepeat,
            "priority": task.priority
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    // edit Task
    func editTask(task: Task) {

    }
    
    // Delete Task
    func deleteTask(task: Task) {

    }
    
    // Send the task to archive
    func archiveTask(task: Task) {

    }
    
}
