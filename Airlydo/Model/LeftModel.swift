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
        
        projectManager.loadOrder {
            self.delegate?.listDidChange()
        }
    }
    
    
    func addList(projectName: String) {
        projectManager.addProject(projectName: projectName)
        delegate?.listDidChange()
    }
    
    func get(index: Int) -> String {
        return projectManager.get(index: index).projectName
    }
    
    func count() -> Int {
        return projectManager.orderArray.count
    }
    
    func reorder(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        projectManager.reorder(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
    
}
