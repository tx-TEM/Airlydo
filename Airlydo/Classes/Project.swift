//
//  Project.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/07/15.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//


// Project
class ProjectX {
    var projectID = ""
    var projectName = ""
    var order: Int
    
    init(projectID: String, projectName: String, order: Int) {
        self.projectID = projectID
        self.projectName = projectName
        self.order = order
    }
}

