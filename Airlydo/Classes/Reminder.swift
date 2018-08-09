//
//  Reminder.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/22.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Firebase

// Reminder
class Reminder {
    var reminderID: String
    
    // Parent Task
    var taskPath: String
    var taskName: String
    
    var dictionary: [String: Any] {
        return ["taskPath": taskPath, "taskName": taskName]
    }
    
    init(taskPath: String, taskName: String) {
        self.reminderID = ""
        self.taskPath = taskPath
        self.taskName = taskName
    }
    
    init(reminderID: String, taskPath: String, taskName: String) {
        self.reminderID = reminderID
        self.taskPath = taskPath
        self.taskName = taskName
    }
    
    convenience init(dictionary: [String: Any], reminderID: String) {
        let taskPath = dictionary["taskPath"] as! String? ?? ""
        let taskName = dictionary["taskName"] as! String? ?? ""
        self.init(reminderID: reminderID, taskPath: taskPath, taskName: taskName)
    }
    
    func saveData() {
        // Firebase
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let dataToSave = self.dictionary
        
        if self.taskPath != "" {
            
            if self.reminderID != "" {
                db.collection(self.taskPath + "/Reminder").document(reminderID).setData(dataToSave) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document Modified with ID: \(self.reminderID)")
                    }
                }
            } else {
                var ref: DocumentReference? = nil
                ref = db.collection(self.taskPath + "/Reminder").addDocument(data: dataToSave) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        self.reminderID = ref!.documentID
                    }
                }
            }
        }
        
    }
}
