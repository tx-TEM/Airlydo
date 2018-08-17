//
//  TaskManager.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import Firebase

struct TableUpdateInfo {
    // need initialize: true
    var isFirst = true
    
    // for call table.insertRow or ...
    var insert = [Int]()
    var remove = [Int]()
    var modify = [Int]()
}

class TaskManager {
    
    // The default TaskManager object
    static var `default`: TaskManager = {
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
    var loadCount = 0
    
    // load Tasks from cloud
    func loadData(projectPath: String, isArchiveMode: Bool, completion: @escaping (TableUpdateInfo) -> ()){
        
        self.loadCount = 0
        print(projectPath + "/Task")
        
        self.listener = db.collection(projectPath + "/Task")
            .whereField("isArchive", isEqualTo: isArchiveMode)
            //.order(by: "dueDate", descending: true)
            //.order(by: "priority", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                var tempTaskList = [Task]()
                var tableUpdateInfo = TableUpdateInfo()
                
                // update TaskList
                for document in snapshot.documents {
                    let tempTask = Task(dictionary: document.data(), taskID: document.documentID, projectPath: projectPath)
                    tempTaskList.append(tempTask)
                }
                
                // get index of diff
                for diff in snapshot.documentChanges {
                    
                    let tempTask = Task(dictionary: diff.document.data(), taskID: diff.document.documentID,
                                        projectPath: projectPath)
                    
                    
                    if (diff.type == .added) {
                        
                        if let index = tempTaskList.index(of: tempTask) {
                            tableUpdateInfo.insert.append(index)
                            print("New: \(tempTask.taskName + "," + tempTask.taskID)")
                        }
                        
                    }
                    
                    if (diff.type == .modified) {
                        
                        if let index = tempTaskList.index(of: tempTask) {
                            tableUpdateInfo.modify.append(index)
                            print("Modified: \(tempTask.taskName)")
                        }
                    }
                    
                    if (diff.type == .removed) {
                        if let index = self.taskList.index(of: tempTask) {
                            tableUpdateInfo.remove.append(index)
                            print("Removed: \(tempTask.taskName)")
                        }
                    }
                    
                }
                self.taskList = tempTaskList
                
                tableUpdateInfo.isFirst = (self.loadCount == 0)
                tableUpdateInfo.remove.reverse()
                print(tableUpdateInfo.remove)
                
                self.loadCount += 1
                
                let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                print("Metadata: Data fetched from \(source)")
                
                completion(tableUpdateInfo)
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
