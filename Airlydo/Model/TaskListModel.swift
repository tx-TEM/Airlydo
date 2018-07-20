//
//  TaskPageModel.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/12.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation
import RealmSwift

protocol TaskListModelDelegate: class {
    func tasksDidChange()
    func errorDidOccur(error: Error)
}

class TaskListModel {
    
    var taskManager = TaskManager()
    
    // Page Status
    var pageTitle = "All"
    var isArchiveMode = false
    var nowProject: Project?
    var sortProperties = [SortDescriptor(keyPath: "dueDate", ascending: true),
                          SortDescriptor(keyPath: "priority", ascending: true) ]
    
    
    // 0: changeList(),  1: changeList(Proj)
    var oldChangeFunc = 0
    
    // Date Formatter
    let dateFormatter = DateFormatter()
    
    // Delegate
    weak var delegate: TaskListModelDelegate?
    
    init() {
        
        // Date Formatter
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = "MMM. d"
    }
    
    
    // Change Display Tasks
    func changeList() {
        //self.tasks = taskManager.readAllData(isArchiveMode: isArchiveMode, sortProperties: sortProperties)
        self.oldChangeFunc = 0
        self.pageTitle = isArchiveMode ? "All <Archive>" : "All"
        delegate?.tasksDidChange()
        self.nowProject = nil
    }
    
    func changeList(selectedProjcet: Project?) {
        
        if let theSelectedProjcet = selectedProjcet {
            //self.tasks = taskManager.readData(isArchiveMode: isArchiveMode, project: theSelectedProjcet, sortProperties: sortProperties)
            self.pageTitle = isArchiveMode ? theSelectedProjcet.projectName + " <Archive>" : theSelectedProjcet.projectName
            
        }else{
            //self.tasks = taskManager.readData(isArchiveMode: isArchiveMode, sortProperties: sortProperties)
            self.pageTitle = isArchiveMode ? "InBox <Archive>" : "InBox"
        }
        
        self.oldChangeFunc = 1
        self.nowProject = selectedProjcet
        delegate?.tasksDidChange()
    }
    
    func changeListOld() {
        
        switch self.oldChangeFunc {
        case 0:
            changeList()

        case 1:
            changeList(selectedProjcet: self.nowProject)
            
        default:
            changeList()
        }
    }
    
    // Change Sort Option
    func changeSortOption(sortProperties: [SortDescriptor]) {
        self.sortProperties = sortProperties
        self.changeListOld()
    }
    
    // Date to String using Formatter
    func dueDateToString(dueDate: Date)-> String {
        return dateFormatter.string(from: dueDate)
    }
    
    // Delete Task
    func deleteTask(indexPath: IndexPath) {
        taskManager.deleteTask(task: taskManager.get(index: indexPath.row))
        delegate?.tasksDidChange()
    }
    
    // Send the task to archive
    func archiveTask(indexPath: IndexPath) {
        taskManager.archiveTask(task: taskManager.get(index: indexPath.row))
        self.delegate?.tasksDidChange()

    }
    
    // Get the Time of after Repeat Calc
    func calcRepeatTime(date: Date, howRepeat: Int)-> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        switch howRepeat {
        // 毎月
        case 0:
            components.month = components.month! + 1
        // 毎週
        case 1:
            components.day = components.day! + 7
        // 毎日
        case 2:
            components.day = components.day! + 1
        default:
            components.day = components.day! + 1
        }
        
        return calendar.date(from: components)!
    }
    
    // Generate Repeat Task
    func genRepeatask(indexPath: IndexPath) {
        let repeatTask = taskManager.get(index: indexPath.row)
        repeatTask.dueDate = calcRepeatTime(date: repeatTask.dueDate, howRepeat: repeatTask.howRepeat)
        
        // Add repeatTask
        taskManager.addTask(task: repeatTask)

        self.delegate?.tasksDidChange()
    }
}
