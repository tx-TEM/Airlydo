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
    
    // The default TaskManager object
    static var `default`: TaskManager = {
        print("Default")
        return TaskManager()
    }()
    
    // Firebase
    let db = Firestore.firestore()
    private var listener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }
    
    var taskList = [Task]()
    
    // load Tasks from cloud
    func loadData(projectPath: String, isArchiveMode: Bool, completed: @escaping () -> ()){
        
        self.taskList = []
        self.listener = db.collection(projectPath + "/Task")
            .whereField("isArchive", isEqualTo: isArchiveMode)
            //.order(by: "dueDate", descending: true)
            //.order(by: "priority", descending: true)
            .addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            for diff in snapshot.documentChanges {
                
                let tempTask = Task(dictionary: diff.document.data(), taskID: diff.document.documentID,
                                    projectPath: projectPath)
                
                if (diff.type == .added) {

                    self.taskList.append(tempTask)
                    print("New: \(tempTask.taskName + "," + tempTask.taskID)")
                }
                
                if (diff.type == .modified) {
                    
                    if let taskIndex = self.taskList.index(of: tempTask) {
                        self.taskList.remove(at: taskIndex)
                    }
                    
                    self.taskList.append(tempTask)
                    print("Modified: \(tempTask.taskName)")
                }
                
                if (diff.type == .removed) {

                    if let taskIndex = self.taskList.index(of: tempTask) {
                        self.taskList.remove(at: taskIndex)
                    }
                    print("Removed: \(tempTask.taskName)")
                }
            }
            
            let source = snapshot.metadata.isFromCache ? "local cache" : "server"
            print("Metadata: Data fetched from \(source)")
            completed()
        }
    }
    
    // load All Data
    func loadAllData (isArchiveMode: Bool) {
        
    }
    
    private func stopLoad() {
        self.listener = nil
    }
    
    func get(index: Int) -> Task {
        return self.taskList[index]
    }
    
    func count() -> Int {
        return self.taskList.count
    }
    
    
    deinit {
        self.stopLoad()
    }
    
}
