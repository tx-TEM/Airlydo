//
//  TaskPageModel.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/06/12.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import Foundation

protocol TaskListModelDelegate: class {
    func tasksDidChange()
    func insertTask(Index: Int)
    func removeTask(Index: Int)
    func updateTask(Index: Int)
    func errorDidOccur(error: Error)
}

struct SortDescriptors {
    var firstOption: NSSortDescriptor
    var secondOption: NSSortDescriptor
    
    init(firstOption: NSSortDescriptor, secondOption: NSSortDescriptor) {
        self.firstOption = firstOption
        self.secondOption = secondOption
    }
}

class TaskListModel {
    
    var taskManager = TaskManager.default
    
    // UITable
    var numberOfRows = 0
    
    // Page Status
    var pageTitle = "InBox"
    var isArchiveMode = false
    private var isAllTask = false
    private var nowProject: Project?
    
    var getNowProject: Project {
        if let nowProject = nowProject {
            return nowProject
        } else {
            return Project()
        }
    }
    
    var sortDescriptors = SortDescriptors(firstOption: NSSortDescriptor(key: "dueDate", ascending: false),
                                          secondOption: NSSortDescriptor(key: "priority", ascending: false))
    
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
    
    
    // Get number of UITable Rows
    func count() -> Int {
        return self.numberOfRows
    }
    
    // Get Task
    func get(index: Int) -> Task {
        return taskManager.get(index: index)
    }
    
    // Delete Task
    func delete(index: Int) {
        taskManager.get(index: index).delete()
    }
    
    
    // Send the task to archive
    func archive(index: Int) {
        taskManager.get(index: index).archive()
    }
    
    
    // Change Display Tasks
    
    /* Change All Project
    func changeProject() {
        //self.tasks = taskManager.readAllData(isArchiveMode: isArchiveMode, sortProperties: sortProperties)
        self.isAllTask = true
        self.pageTitle = isArchiveMode ? "All <Archive>" : "All"
        delegate?.tasksDidChange()
        self.nowProject = nil
    }
    */
    
    func changeProject(selectedProjcet: Project) {
        
        self.pageTitle = self.isArchiveMode ? selectedProjcet.projectName + " <Archive>" : selectedProjcet.projectName
        self.nowProject = selectedProjcet
        self.isAllTask = false
        
        self.taskManager.loadData(projectPath: selectedProjcet.projectPath, sortDescriptors: sortDescriptors,
                                  isArchiveMode: isArchiveMode, completion: { tableUpdateInfo in
            
            // Update Table
            self.differentialUpdate(tableUpdateInfo: tableUpdateInfo)

        })
    }
    
    func changeProjectOld() {
        if let nowProj = self.nowProject {
            changeProject(selectedProjcet: nowProj)
        } else {
            if(isAllTask) {
                //changeProject()
            }
        }
    }
    
    // Change Sort Option
    func changeSortOption(sortDescriptors: SortDescriptors) {
        self.sortDescriptors = sortDescriptors
        self.changeProjectOld()
    }
    
    // Differential update of TaskList Table
    private func differentialUpdate(tableUpdateInfo: TableUpdateInfo) {
        
        if (tableUpdateInfo.isFirst) {
            
            // initialize Table
            self.numberOfRows = self.taskManager.count()
            self.delegate?.tasksDidChange()
            
        } else {
            
            // remove
            for index in tableUpdateInfo.remove {
                self.numberOfRows -= 1
                self.delegate?.removeTask(Index: index)
            }
            
            // insert
            for index in tableUpdateInfo.insert {
                self.numberOfRows += 1
                self.delegate?.insertTask(Index: index)
            }
            
            // modify
            for index in tableUpdateInfo.modify {
                self.delegate?.updateTask(Index: index)
            }
            
        }
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
    
    // Get the Time of after Repeat Calc
    private func calcRepeatTime(date: Date, howRepeat: Int)-> Date {
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
    
    // Date to String using Formatter
    func dueDateToString(dueDate: Date)-> String {
        return dateFormatter.string(from: dueDate)
    }

}
