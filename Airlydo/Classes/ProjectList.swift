//
//  ProjectList.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import Firebase

class ProjectList {
    
    // Firebase
    let db = Firestore.firestore()
    
    var projectDic = [String:ProjectX]()
    var orderArray = [String]()
    
    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // load Projects
    func loadData(completed: @escaping () -> ()){
        db.collection("User/user1/Project").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            for diff in snapshot.documentChanges {
                if (diff.type == .added || diff.type == .modified) {
                    print("New or Modified: \(diff.document.data())")
                    if let projName = diff.document.data()["projectName"] {
                        let tempProj = ProjectX(projectID: diff.document.documentID,
                                                projectName: projName as! String)
                        
                        self.projectDic[diff.document.documentID] = tempProj
                    }
                }
                
                if (diff.type == .removed) {
                    print("Removed: \(diff.document.data())")
                    self.projectDic.removeValue(forKey: diff.document.documentID)
                }
            }
            completed()
        }
    }
    
    // load Order
    func loadOrder(completed: @escaping () -> ()){
        db.collection("User/user1/etc").document("order").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return completed()
            }
            
            if let docData = document.data() {
                if let order = docData["projectOrder"] {
                    self.orderArray = order as! [String]
                    print(self.orderArray)
                }
            }
            completed()
        }
    }
    
    // Add new Project, save to firestore
    func addProject(projectName: String) {
        
        if(!(projectName.isEmpty)) {
            // Add a new document with a generated ID
            
            var ref: DocumentReference? = nil
            ref = db.collection("User/user1/Project").addDocument(data: [
                "projectName": projectName,
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        self.orderArray.append(ref!.documentID)
                        
                        self.db.collection("User/user1/etc").document("order").setData([
                            "projectOrder": self.orderArray
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            }
                        }
                    }
            }
            
        }
        
    }
    
    func get(index: Int) -> ProjectX {
        return projectDic[orderArray[index]]!
    }
    
    // reorder Project List
    func reorder(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        
    }
    
}