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
    // need initialize Table: true
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
    func loadData(projectPath: String, sortDescriptors: SortDescriptors, isArchiveMode: Bool, completion: @escaping (TableUpdateInfo) -> ()){
        
        guard let firstKey = sortDescriptors.firstOption.key,
              let secondKey = sortDescriptors.secondOption.key else {
                
            return
        }
        
        self.loadCount = 0
        print(projectPath + "/Task")
        
        self.listener = db.collection(projectPath + "/Task")
            .whereField("isArchive", isEqualTo: isArchiveMode)
            .order(by: firstKey, descending: sortDescriptors.firstOption.ascending)
            .order(by: secondKey, descending: sortDescriptors.secondOption.ascending)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                var newTaskList = [Task]()
                var tableUpdateInfo = TableUpdateInfo()
                
                // update TaskList
                for document in snapshot.documents {
                    let tempTask = Task(dictionary: document.data(), taskID: document.documentID, projectPath: projectPath)
                    newTaskList.append(tempTask)
                }
                
                // get index of diff
                for diff in snapshot.documentChanges {
                    
                    let tempTask = Task(dictionary: diff.document.data(), taskID: diff.document.documentID,
                                        projectPath: projectPath)
                    
                    
                    if (diff.type == .added) {
                        
                        guard let index = newTaskList.index(of: tempTask) else {
                                return
                        }
                        
                        tableUpdateInfo.insert.append(index)
                        print("New: \(tempTask.taskName + "," + tempTask.taskID)")
                        
                    }
                    
                    if (diff.type == .modified) {
                        
                        guard let oldIndex = self.taskList.index(of: tempTask),
                              let newIndex = newTaskList.index(of: tempTask) else {
                                return
                        }
                        
                        // don't need Move
                        if oldIndex == newIndex {
                            tableUpdateInfo.modify.append(newIndex)
                            
                        } else {
                            tableUpdateInfo.remove.append(oldIndex)
                            tableUpdateInfo.insert.append(newIndex)
                        }
                        
                        print("Modified: \(tempTask.taskName)")
                        
                    }
                    
                    if (diff.type == .removed) {
                        
                        guard let index = self.taskList.index(of: tempTask) else {
                            return
                        }
                        
                        tableUpdateInfo.remove.append(index)
                        print("Removed: \(tempTask.taskName)")
                    }
                    
                }
                
                // update taslList
                self.taskList = newTaskList
                
                tableUpdateInfo.isFirst = (self.loadCount == 0)
                tableUpdateInfo.remove.reverse()
                
                self.loadCount += 1
                
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
