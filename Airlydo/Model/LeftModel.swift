//
//  LeftViewModel_CustomList.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/12.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import RealmSwift

protocol LeftModelDelegate: class {
    func listDidChange()
    func errorDidOccur(error: Error)
}

class LeftModel {
    
    var projectManager = ProjectManager()
    
    // Delegate
    weak var delegate: LeftModelDelegate?
    
    init() {
        projectManager.loadData {
            self.delegate?.listDidChange()
        }
    }
    
    
    func addList(projectName: String) {
        projectManager.add(projectName: projectName)
        delegate?.listDidChange()
        print("change")
    }
    
    func get(index: Int) -> Project {
        return projectManager.get(index: index)
    }
    
    func getInBox() -> Project {
        return projectManager.getInBox
    }
    
    func getProjectDic() -> [String:Project] {
        return projectManager.getProjectDic
    }
    
    func getProjectList() -> [Project] {
        return projectManager.getProjectList()
    }
    
    func count() -> Int {
        return projectManager.count()
    }
    
    func reorder(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        projectManager.reorder(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
    
}
