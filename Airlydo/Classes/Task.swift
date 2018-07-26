//
//  Task.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Firebase

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
    var projectPath: String
    
    // getter for save data
    var dictionary: [String: Any] {
        return ["taskName": taskName,
                "note": note,
                "isArchive": isArchive,
                "dueDate": dueDate,
                "howRepeat": howRepeat,
                "priority": priority]
    }
    
    init() {
        self.taskID = ""
        self.taskName = ""
        self.note = ""
        self.isArchive = false
        self.dueDate = Date()
        self.howRepeat = 3
        self.priority = 1
        self.projectPath = "/User/user1/DefaultProject/InBox"
    }
    
    init(taskID: String, taskName: String, note: String, isArchive: Bool,
         dueDate: Date, howRepeat: Int, priority: Int, projectPath: String) {
        
        self.taskID = taskID
        self.taskName = taskName
        self.note = note
        self.isArchive = isArchive
        self.dueDate = dueDate
        self.howRepeat = howRepeat
        self.priority = priority
        self.projectPath = projectPath
    }
    
    // For firestore
    convenience init(dictionary: [String: Any], taskID: String, projectPath: String) {
        let taskName = dictionary["taskName"] as! String? ?? ""
        let note = dictionary["note"] as! String? ?? ""
        let isArchive = dictionary["isArchive"] as! Bool? ?? false
        
        let dueDateTimeStamp = dictionary["dueDate"] as! Timestamp? ?? Timestamp(date: Date())
        let dueDate = dueDateTimeStamp.dateValue()
        
        let howRepeat = dictionary["howRepeat"] as! Int? ?? 3
        let priority = dictionary["priority"] as! Int? ?? 1
        
        self.init(taskID: taskID, taskName: taskName, note: note, isArchive: isArchive,
                  dueDate: dueDate, howRepeat: howRepeat, priority: priority, projectPath: projectPath)
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        // Firebase
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let dataToSave = dictionary
        
        if taskID != "" {  //update Data
            db.collection(self.projectPath + "/Task").document(taskID).setData(dataToSave) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completed(false)
                } else {
                    print("Document Modified with ID: \(self.taskID)")
                    completed(true)
                }
            }
            
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection(self.projectPath + "/Task").addDocument(data: dataToSave) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completed(false)
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.taskID = ref!.documentID
                    completed(true)
                }
            }
        }
        
    }
    
    // Delete Task
    func delete() {
        
    }
    
    // Send the task to archive
    func archive() {
        
    }
        
}
