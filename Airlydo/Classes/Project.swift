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
    var projectDirPath: String  // Project, DefaultProject, ShareProject
    
    // getter: save data
    var dictionary: [String: Any] {
        return ["projectName": projectName]
    }
    
    // getter: project full Path
    var projectPath: String {
        return self.projectDirPath + "/" + self.projectID
    }
    
    init() {
        self.projectID = "InBox"
        self.projectName = "InBox"
        let cUser = Auth.auth().currentUser!
        self.projectDirPath = "/User/" + cUser.uid + "/DefaultProject"

    }
    
    init(projectName: String, projectDirPath: String) {
        self.projectID = ""
        self.projectName = projectName
        self.projectDirPath = projectDirPath
    }
    
    init(projectID: String, projectName: String, projectDirPath: String) {
        self.projectID = projectID
        self.projectName = projectName
        self.projectDirPath = projectDirPath
    }
    
    // For firestore
    convenience init(dictionary: [String: Any], projectID: String, projectDirPath: String) {
        let projectName = dictionary["projectName"] as! String? ?? ""
        self.init(projectID: projectID, projectName: projectName, projectDirPath: projectDirPath)
    }
    
    func saveData(completion: @escaping (String) -> ()) {
        // Firebase
        let db = Firestore.firestore()
        
        let dataToSave = dictionary
        
        // update
        if projectID != "" {
            db.collection(projectDirPath).document(projectID).setData(dataToSave) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion("")
                } else {
                    print("Document Modified with ID: \(self.projectID)")
                    completion(self.projectPath)
                }
            }
            
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection(projectDirPath).addDocument(data: dataToSave) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completion("")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.projectID = ref!.documentID
                    completion(self.projectPath)
                }
            }
        }
    }
}

