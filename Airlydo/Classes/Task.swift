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
    var projectID = ""
    
    // getter for save data
    var dictionary: [String: Any] {
        return ["taskName": taskName,
                "note": note,
                "isArchive": isArchive,
                "dueDate": dueDate,
                "howRepeat": howRepeat,
                "priority": priority,
                "projectID": projectID]
    }
    
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
    
    // For firestore
    convenience init(dictionary: [String: Any], taskID: String) {
        let taskName = dictionary["taskName"] as! String? ?? ""
        let note = dictionary["note"] as! String? ?? ""
        let isArchive = dictionary["isArchive"] as! Bool? ?? false
        let dueDate = dictionary["dueDate"] as! Date? ?? Date()
        let howRepeat = dictionary["howRepeat"] as! Int? ?? 3
        let priority = dictionary["priority"] as! Int? ?? 1
        let projectID = dictionary["projectID"] as! String? ?? "InBox"
        
        self.init(taskID: taskID, taskName: taskName, note: note, isArchive: isArchive,
                  dueDate: dueDate, howRepeat: howRepeat, priority: priority, projectID: projectID)
    }
    
    func saveData() {
        // Firebase
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let dataToSave = dictionary
        
        if taskID != "" {  //update Data
            db.collection("User/user1/Project/" + projectID + "/Task").document(taskID).setData(dataToSave) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document Modified with ID: \(self.taskID)")
                }
            }
            
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("User/user1/Project/" + projectID + "Task").addDocument(data: dataToSave) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.taskID = ref!.documentID
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
