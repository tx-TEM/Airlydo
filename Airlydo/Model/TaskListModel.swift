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
    func insertTask(Index: Int)
    func removeTask(Index: Int)
    func errorDidOccur(error: Error)
}

class TaskListModel {
    
    var taskManager = TaskManager.default
    
    // Page Status
    var pageTitle = "InBox"
    var isArchiveMode = false
    private var isAllTask = false
    private var nowProject: Project?
    
    var sortProperties = [SortDescriptor(keyPath: "dueDate", ascending: true),
                          SortDescriptor(keyPath: "priority", ascending: true) ]
    
    enum SortOptions: String {
        case dueDate = "dueDate"
        case priority = "priority"
    }
    
    
    // Date Formatter
    let dateFormatter = DateFormatter()
    
    // Delegate
    weak var delegate: TaskListModelDelegate?
    
    init() {
        self.nowProject = Project() //InBox
        
        taskManager.loadData(projectPath: (nowProject?.projectPath)!, isArchiveMode: isArchiveMode, completion: { tableUpdateInfo in
            
            if (tableUpdateInfo.isFirst) {
                
                // initialize Table
                self.delegate?.tasksDidChange()
                
            } else {
                
                // remove
                for index in tableUpdateInfo.remove {
                    self.delegate?.removeTask(Index: index)
                }
                
                // insert
                for index in tableUpdateInfo.insert {
                    self.delegate?.insertTask(Index: index)
                }
                
                // modify
                //for index in tableUpdateInfo.modify {
                //    self.delegate?.insertTask(Index: index)
                //}
            
            }
 
        })
 
        // Date Formatter
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = "MMM. d"
    }
    
    
    // Change Display Tasks
    func changeProject() {
        //self.tasks = taskManager.readAllData(isArchiveMode: isArchiveMode, sortProperties: sortProperties)
        self.isAllTask = true
        self.pageTitle = isArchiveMode ? "All <Archive>" : "All"
        delegate?.tasksDidChange()
        self.nowProject = nil
    }
    
    func changeProject(selectedProjcet: Project) {
        
        self.pageTitle = self.isArchiveMode ? selectedProjcet.projectName + " <Archive>" : selectedProjcet.projectName
        self.nowProject = selectedProjcet
        self.isAllTask = false
        
        self.taskManager.loadData(projectPath: selectedProjcet.projectPath, isArchiveMode: isArchiveMode, completion: { tableUpdateInfo in
            
            if (tableUpdateInfo.isFirst) {
                
                // initialize Table
                self.delegate?.tasksDidChange()
                
            } else {
                
                // remove
                for index in tableUpdateInfo.remove {
                    self.delegate?.removeTask(Index: index)
                }
                
                // insert
                for index in tableUpdateInfo.insert {
                    self.delegate?.insertTask(Index: index)
                }
                
                // modify
                //for index in tableUpdateInfo.modify {
                //    self.delegate?.insertTask(Index: index)
                //}
                
            }
            
        })
    }
    
    func changeProjectOld() {
        if let nowProj = self.nowProject {
            changeProject(selectedProjcet: nowProj)
        } else {
            if(isAllTask) {
                changeProject()
            }
        }
    }
    
    // Change Sort Option
    func changeSortOption(sortProperties: [SortDescriptor]) {
        self.sortProperties = sortProperties
        self.changeProjectOld()
    }
    
    // Date to String using Formatter
    func dueDateToString(dueDate: Date)-> String {
        return dateFormatter.string(from: dueDate)
    }
    
    // Delete Task
    func deleteTask(index: Int) {
        taskManager.get(index: index).delete()
        
    }
    
    // Send the task to archive
    func archiveTask(index: Int) {
        taskManager.get(index: index).archive()

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
    func genRepeatask(index: Int) {
        let baseTask = taskManager.get(index: index)
        let repeatTask = baseTask.copy()
        
        // update
        repeatTask.taskID = ""
        repeatTask.dueDate = calcRepeatTime(date: baseTask.dueDate, howRepeat: baseTask.howRepeat)
        repeatTask.reminderList = []
        
        for reminder in baseTask.reminderList {
            repeatTask.reminderList.append(calcRepeatTime(date: reminder, howRepeat: baseTask.howRepeat))
        }
        
        // save repeatTask
        repeatTask.saveData() { success in
            if(success) {
                print("complete")
            }
        }
    }
    
    func count() -> Int {
        return taskManager.taskList.count
    }
    
    func get(index: Int) -> Task {
        return taskManager.get(index: index)
    }
    
    func delete(index: Int) {
        taskManager.get(index: index).delete()
    }
    
    func archive(index: Int) {
        taskManager.get(index: index).archive()
    }
}
