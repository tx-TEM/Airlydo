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
    private var listener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }
    
    var taskList = [Task]()
    
    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    
    // load Tasks from cloud
    func loadData(projectPath: String, isArchiveMode: Bool, completed: @escaping () -> ()){
        
        self.taskList = []
        self.listener = db.collection(projectPath + "/Task")
            .whereField("isArchive", isEqualTo: isArchiveMode).addSnapshotListener { querySnapshot, error in
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
                    let tempTask = Task(dictionary: diff.document.data(), taskID: diff.document.documentID,
                                        projectPath: projectPath)
                    
                    if let taskIndex = self.taskList.index(of: tempTask) {
                        self.taskList.remove(at: taskIndex)
                    }
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
