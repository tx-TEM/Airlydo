//
//  ProjectManager.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/20.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class ProjectManager {
    
    // Firebase
    let db = Firestore.firestore()
    
    var projectArray: Array<ProjectX> = []
    
    init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // Read Project
    func loadData(completed: @escaping () -> ()){
        db.collection("User/user1/Project").order(by: "order", descending: false).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return completed()
            }
            
            self.projectArray = []
            
            for document in documents {
                
                let tempProj = ProjectX(projectID: document.documentID,
                                       projectName: document.data()["projectName"] as! String,
                                       order: document.data()["order"] as! Int)
                print(tempProj.projectName)
                self.projectArray.append(tempProj)
            }
            completed()
        }
    }
    // Add new Project
    func addProject(projectName: String) {
        
        if(!(projectName.isEmpty)) {
            // Add a new document with a generated ID
            
            var ref: DocumentReference? = nil
            ref = db.collection("User/user1/Project").addDocument(data: [
                "projectName": projectName,
                "order": self.projectArray.count + 1
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
    }
    
    // reorder Project List
    func reorder(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let sourceOrder = self.projectArray[sourceIndexPath.row].order
        let destOrder = self.projectArray[destinationIndexPath.row].order
        
        db.collection("User/user1/Project").document(self.projectArray[sourceIndexPath.row].projectID).updateData([
            "order": destOrder,
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        db.collection("User/user1/Project").document(self.projectArray[destinationIndexPath.row].projectID).updateData([
            "order": sourceOrder,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
        }
    }
    
}
