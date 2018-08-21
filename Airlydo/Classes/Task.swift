//
//  Task.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Firebase

// Task
class Task {
    var taskID: String
    var taskName: String
    var note: String
    var isArchive: Bool
    var dueDate: Date
    var reminderList = [Date]()
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
                "reminderList": reminderList,
                "howRepeat": howRepeat,
                "priority": priority]
    }
    
    
    init() {
        self.taskID = ""
        self.taskName = ""
        self.note = ""
        self.isArchive = false
        self.dueDate = Date()
        self.reminderList = []
        self.howRepeat = 3
        self.priority = 1
        self.projectPath = ""
    }
    
    init(taskID: String, taskName: String, note: String, isArchive: Bool,dueDate: Date,
         reminderList: [Date], howRepeat: Int, priority: Int, projectPath: String) {
        
        self.taskID = taskID
        self.taskName = taskName
        self.note = note
        self.isArchive = isArchive
        self.dueDate = dueDate
        self.reminderList = reminderList
        self.howRepeat = howRepeat
        self.priority = priority
        self.projectPath = projectPath
    }
    
    // For firestore
    convenience init(dictionary: [String: Any], taskID: String, projectPath: String) {
        let taskName = dictionary["taskName"] as! String? ?? ""
        let note = dictionary["note"] as! String? ?? ""
        let isArchive = dictionary["isArchive"] as! Bool? ?? false
        
        // convert Timestamp to Date
        let dueDateTimeStamp = dictionary["dueDate"] as! Timestamp? ?? Timestamp(date: Date())
        let dueDate = dueDateTimeStamp.dateValue()
        
        // convert [Timestamp] to [Date]
        let reminderListTimeStamp = dictionary["reminderList"] as! [Timestamp]? ?? [Timestamp]()
        var reminderList = [Date]()
        for reminderTimestamp in reminderListTimeStamp {
            reminderList.append(reminderTimestamp.dateValue())
        }
        
        let howRepeat = dictionary["howRepeat"] as! Int? ?? 3
        let priority = dictionary["priority"] as! Int? ?? 1
        
        self.init(taskID: taskID, taskName: taskName, note: note, isArchive: isArchive, dueDate: dueDate,
                  reminderList: reminderList, howRepeat: howRepeat, priority: priority, projectPath: projectPath)
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        // Firebase
        let db = Firestore.firestore()
        
        let dataToSave = dictionary
        
        if taskID != "" {  //update Data
            db.collection(self.projectPath + "/Task").document(self.taskID).setData(dataToSave) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
            
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection(self.projectPath + "/Task").addDocument(data: dataToSave) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completion(false)
                } else {
                    self.taskID = ref!.documentID
                    completion(true)
                }
            }
        }
        
    }
    
    // Delete Task
    func delete() {
        // Firebase
        let db = Firestore.firestore()
        
        db.collection(self.projectPath + "/Task").document(self.taskID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            }
        }
        
    }
    
    // Send the task to archive
    func archive() {
        // Firebase
        let db = Firestore.firestore()
        
        db.collection(self.projectPath + "/Task").document(self.taskID).updateData([
            "isArchive": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
    
    // Copy
    func copy() -> Task {
        let instance = Task(taskID: self.taskID,
                            taskName: self.taskName,
                            note: self.note,
                            isArchive: self.isArchive,
                            dueDate: self.dueDate,
                            reminderList: self.reminderList,
                            howRepeat: self.howRepeat,
                            priority: self.priority,
                            projectPath: self.projectPath)
        
        return instance
    }
        
}

extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.taskID == rhs.taskID && lhs.projectPath == rhs.projectPath
    }
}
