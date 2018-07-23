//
//  Project.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/15.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Firebase

// Project
class Project {
    var projectID: String
    var projectName: String
    
    // getter for save data
    var dictionary: [String: Any] {
        return ["projectName": projectName]
    }
    
    init() {
        self.projectID = ""
        self.projectName = ""
    }
    
    init(projectID: String, projectName: String) {
        self.projectID = projectID
        self.projectName = projectName
    }
    
    // For firestore
    convenience init(dictionary: [String: Any], projectID: String) {
        let projectName = dictionary["projectName"] as! String? ?? ""
        self.init(projectID: projectID, projectName: projectName)
    }
    
    func saveData() {
        // Firebase
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let dataToSave = dictionary
        
        if projectID != "" {
            db.collection("User/user1/Project/").document(projectID).setData(dataToSave) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document Modified with ID: \(self.projectID)")
                }
            }
            
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("User/user1/Project/").addDocument(data: dataToSave) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.projectID = ref!.documentID
                }
            }
        }
    }
}

