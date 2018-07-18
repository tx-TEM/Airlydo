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
    
    var projectList = ProjectList()
    
    // Delegate
    weak var delegate: LeftModelDelegate?
    
    init() {
        projectList.loadData {
            self.delegate?.listDidChange()
        }
        
        projectList.loadOrder {
            self.delegate?.listDidChange()
        }
    }
    
    
    func addList(projectName: String) {
        projectList.addProject(projectName: projectName)
        
        delegate?.listDidChange()
    }
    
    func get(index: Int) -> String {
        print(projectList.get(index: index).projectName)
        return projectList.get(index: index).projectName
    }
    
    func count() -> Int {
        return projectList.orderArray.count
    }
    
    func reorder(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        projectList.reorder(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
    
}
