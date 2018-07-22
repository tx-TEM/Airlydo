//
//  Project.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/15.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//


// Project
class Project {
    var projectID: String
    var projectName: String
    
    init() {
        self.projectID = ""
        self.projectName = ""
    }
    
    init(projectID: String, projectName: String) {
        self.projectID = projectID
        self.projectName = projectName
    }
}

