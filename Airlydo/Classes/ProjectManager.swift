//
//  ProjectManager.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Firebase

class ProjectManager {
    
    // The default ProjectManager object
    static var `default`: ProjectManager = {
        print("Default")
        return ProjectManager()
    }()
    
    
    // Firebase
    let db = Firestore.firestore()
    private var listener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }
    
    // [inBox Instance (Default Project)]
    private var inbox: Project
    
    var getInBox: Project {
        return self.inbox
    }
    
    // All Project Instance
    private var projectDic = [String:Project]()
    
    var getProjectDic: [String:Project] {
        return self.projectDic
    }
    
    // [custom & shared Project] Order
    private var projectOrder = [String]()
    
    
    let userDefaults = UserDefaults.standard
    
    // Project Directory Path
    let defaultProjectPath = "/User/user1/DefaultProject"
    let customProjectPath = "/User/user1/CustomProject"
    let sharedProjectPath = "/User/UserID/SharedProject"
    
    init() {
        
        inbox = Project(projectID: "InBox", projectName: "InBox", projectDirPath: defaultProjectPath)
        projectDic[inbox.projectPath] = inbox
        
        readOrder()
    }
    
    // load Projects from cloud
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
                    let tempProjPath = self.customProjectPath + "/" + diff.document.documentID
                    
                    let tempProj = Project(dictionary: diff.document.data(), projectID: diff.document.documentID,
                                           projectDirPath: self.customProjectPath)
                    
                    self.projectDic[tempProjPath] = tempProj

                    if !(self.projectOrder.contains(tempProjPath)) {
                        self.projectOrder.append(tempProjPath)
                    }
                }
                
                if (diff.type == .removed) {
                    print("Removed: \(diff.document.data())")
                    let tempProjPath = self.customProjectPath + "/" + diff.document.documentID
                    
                    self.projectDic.removeValue(forKey: tempProjPath)
                    
                    if let projIndex = self.projectOrder.index(of: tempProjPath) {
                        self.projectOrder.remove(at: projIndex)
                    }
                }
                
            }
            
            // remove projectkeys that has been erased by the other device
            let projectKeys = [String](self.projectDic.keys)
            for (index, key) in self.projectOrder.enumerated() {
                if !(projectKeys.contains(key)) {
                    self.projectOrder.remove(at: index)
                }
            }
            
            let source = snapshot.metadata.isFromCache ? "local cache" : "server"
            print("Metadata: Data fetched from \(source)")
            self.saveOrder(order: self.projectOrder)
            print(self.projectOrder)
            completed()
        }
        
        // load SharedProject
        
        //
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
    
    // get sorted Project List
    func getProjectList() -> [Project] {
        var reList = [Project]()
        
        // 1st is InBox (Default Project)
        reList.append(self.inbox)
        
        // Custom & Shared Project
        for key in self.projectOrder {
            if let proj = self.projectDic[key] {
                reList.append(proj)
            }
        }
        return reList
    }
    
    // count
    func count() -> Int {
        return projectOrder.count
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
