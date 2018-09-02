//
//  ProjectManager.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Firebase

struct ProjectDirPath {
    
    // Path
    let defaultProjectPath: String
    let customProjectPath: String
    let sharedProjectPath: String
    
    init() {
        if let cUser = Auth.auth().currentUser {
            
            defaultProjectPath = "/User/" + cUser.uid + "/DefaultProject"
            customProjectPath = "/User/" + cUser.uid + "/CustomProject"
            sharedProjectPath = "/User/" + cUser.uid + "/SharedProject"
        } else {
            defaultProjectPath = "/User/user1/DefaultProject"
            customProjectPath = "/User/user1/CustomProject"
            sharedProjectPath = "/User/user1/SharedProject"
        }
    }
}

class ProjectManager {
    
    // The default ProjectManager object
    static var `default`: ProjectManager = {
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
    //private var projectOrder = [String]()
    var projectOrder = [String]()
    
    let userDefaults = UserDefaults.standard
    
    let projectDirPath = ProjectDirPath()
    
    init() {
        inbox = Project(projectID: "InBox", projectName: "InBox", projectDirPath: projectDirPath.defaultProjectPath)
        projectDic[inbox.projectPath] = inbox
        
        readOrder()
    }
    
    // load Projects from cloud
    func loadData(completion: @escaping () -> ()){
        
        // load CustomProject
        self.listener = db.collection(projectDirPath.customProjectPath).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            for diff in snapshot.documentChanges {
                if (diff.type == .added || diff.type == .modified) {
                    print("New or Modified: \(diff.document.data())")
                    let tempProjPath = self.projectDirPath.customProjectPath + "/" + diff.document.documentID
                    
                    let tempProj = Project(dictionary: diff.document.data(), projectID: diff.document.documentID,
                                           projectDirPath: self.projectDirPath.customProjectPath)
                    
                    self.projectDic[tempProjPath] = tempProj

                    if !(self.projectOrder.contains(tempProjPath)) {
                        self.projectOrder.append(tempProjPath)
                    }
                }
                
                if (diff.type == .removed) {
                    print("Removed: \(diff.document.data())")
                    let tempProjPath = self.projectDirPath.customProjectPath + "/" + diff.document.documentID
                    
                    self.projectDic.removeValue(forKey: tempProjPath)
                    
                    if let projIndex = self.projectOrder.index(of: tempProjPath) {
                        self.projectOrder.remove(at: projIndex)
                    }
                }
                
                print(self.projectOrder)
            }
            
            
            let source = snapshot.metadata.isFromCache ? "local cache" : "server"
            print("Metadata: Data fetched from \(source)")
            self.saveOrder(order: self.projectOrder)
            print(self.projectOrder)
            completion()
        }
        
        // load SharedProject
        
        //
    }
    
    private func stopLoad() {
        listener = nil
    }
    
    // read Project Order form UserDefault
    func readOrder() {
        print("readOrder")
        print(self.projectOrder)
        self.projectOrder = userDefaults.object(forKey: "ProjectOrder") as? [String] ?? []
        print(self.projectOrder)
    }
    
    // save Project order to UserDefault
    func saveOrder(order: [String]) {
        userDefaults.set(order, forKey: "ProjectOrder")
    }
    
    
    // Add new CustomProject, save to firestore
    func add(projectName: String) {
        
        if(!(projectName.isEmpty)) {
            let newProject = Project(projectName: projectName, projectDirPath: self.projectDirPath.customProjectPath)
            
            newProject.saveData { newProjectPath in
                if newProjectPath == "" {
                    print("failed to save Project")
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
