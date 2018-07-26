//
//  TaskManager.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import Firebase

class TaskManager {
    
    // Firebase
    let db = Firestore.firestore()
    
    var taskList = [Task]()
    
    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    
    // load Tasks from cloud
    func loadData(isArchiveMode: Bool, projectPath: String, completed: @escaping () -> ()){
        db.collection(projectPath + "/Task").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            for diff in snapshot.documentChanges {
                if (diff.type == .added || diff.type == .modified) {
                    print("New or Modified: \(diff.document.data())")
                    let tempTask = Task(dictionary: diff.document.data(), taskID: diff.document.documentID,
                                        projectPath: projectPath)
                    self.taskList.append(tempTask)
                }
                
                if (diff.type == .removed) {
                    print("Removed: \(diff.document.data())")
                }
            }
            completed()
        }
    }
    
    // load All Data
    func loadAllData (isArchiveMode: Bool) {

    }
    
    func get(index: Int) -> Task {
        return taskList[index]
    }
    
    
}
