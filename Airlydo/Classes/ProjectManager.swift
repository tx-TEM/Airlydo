//
//  ProjectManager.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift

class ProjectManager {
    
    // Firebase
    let db = Firestore.firestore()
    private var listener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }
    
    
    // data
    var projectDic = [String:Project]()
    var projectOrder = [String]()
    
    let userDefaults = UserDefaults.standard
    
    // DirPath
    let customProjectPath = "/User/user1/CustomProject"
    
    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        readOrder()
        print(projectOrder)
    }
    
    // load Projects from cloud
    //  /User/userID/DefaultProject       : DefaultProject
    //  /User/userID/CustomProject        : CustomProject
    //  /User/UserID/SharedProject        : SharedProject
    
    func loadData(completed: @escaping () -> ()){
        
        // load CustomProject
        db.collection(customProjectPath).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            for diff in snapshot.documentChanges {
                if (diff.type == .added || diff.type == .modified) {
                    print("New or Modified: \(diff.document.data())")
                    let tempProj = Project(dictionary: diff.document.data(), projectID: diff.document.documentID,
                                           projectDirPath: self.customProjectPath)
                    
                    self.projectDic[tempProj.projectPath] = tempProj
                }
                
                if (diff.type == .removed) {
                    print("Removed: \(diff.document.data())")
                    self.projectDic.removeValue(forKey: diff.document.documentID)
                }
                
            }
            let source = snapshot.metadata.isFromCache ? "local cache" : "server"
            print("Metadata: Data fetched from \(source)")
            completed()
        }
    }
    
    private func stopLoad() {
        listener = nil
    }
    
    // read Project Order form UserDefault
    func readOrder() {
        self.projectOrder = userDefaults.object(forKey: "ProjectOrder") as? [String] ?? []
    }
    
    // save Project order to UserDefault
    func saveOrder(order: [String]) {
        userDefaults.set(order, forKey: "ProjectOrder")
    }
    
    // need update Project order?
    func updateOrder(projectPath: String) {
    }
    
    
    // Add new CustomProject, save to firestore
    func add(projectName: String) {
        
        if(!(projectName.isEmpty)) {
            let newProject = Project(projectName: projectName, projectDirPath: self.customProjectPath)
            
            newProject.saveData { newProjectPath in
                if newProjectPath != "" {
                    self.projectOrder.append(newProjectPath)
                    self.saveOrder(order: self.projectOrder)
                }
            }
        }
        
    }
    
    func get(index: Int) -> Project {
        if let theProject = projectDic[projectOrder[index]] {
            return theProject
        }else{
            return Project()
        }
    }
    
    func getArray() -> [Project] {
        var reArray = [Project]()
        
        for order in projectOrder {
            reArray.append(projectDic[order]!)
        }
        
        return reArray
    }
    
    // reorder Project List
    func reorder(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let tempID = projectOrder[sourceIndexPath.row]
        self.projectOrder.remove(at: sourceIndexPath.row)
        self.projectOrder.insert(tempID, at: destinationIndexPath.row)
        
        self.saveOrder(order: projectOrder)
    }
    
    deinit {
        self.stopLoad()
    }
    
}
