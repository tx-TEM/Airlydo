//
//  TaskPageController.swift
//  ToDoList
//
//  Created by yoshiki-t on 2018/05/16.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import UIKit
import MCSwipeTableViewCell
import SlideMenuControllerSwift
import Firebase

class TaskListViewController: UIViewController {

    @IBOutlet weak var TaskCellTable: UITableView!
    @IBOutlet weak var AddTaskButton: UIBarButtonItem!
    @IBOutlet weak var MainButton: UIButton!
    @IBOutlet weak var ArchiveButton: UIButton!
    @IBOutlet weak var SortButton: UIButton!
    
    
    let taskListModel = TaskListModel()
    var cellHeight = 100.0
    var cellClose = [Int]()

    
    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        
        guard let TaskDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetailViewController") as? TaskDetailViewController else {
            return
        }
        
        // Set new Task
        TaskDetailViewController.taskDetailModel = TaskDetailModel(defaultProjectPath: self.taskListModel.getNowProject.projectPath)
        self.navigationController?.pushViewController(TaskDetailViewController, animated: true)
    }
    
    @IBAction func mainButtonTapped(_ sender: UIButton) {
        taskListModel.isArchiveMode = false
        taskListModel.changeProjectOld()
    }

    @IBAction func archiveButtonTapped(_ sender: UIButton) {
        taskListModel.isArchiveMode = true
        taskListModel.changeProjectOld()
    }
    
    @IBAction func projectSettingButtonTapped(_ sender: UIButton) {
        
        self.TaskCellTable.reloadData()
        //let ProjectSettingViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProjectSettingViewController") as! ProjectSettingViewController
        //self.navigationController?.pushViewController(ProjectSettingViewController, animated: true)
    }

    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        let controller = UIAlertController(title: "Sort",
                                           message: nil,
                                           preferredStyle: .actionSheet)
        
        // Add Action
        controller.addAction(UIAlertAction(title: "dueDate", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.taskListModel.changeSortOption(sortDescriptors: SortDescriptors(firstOption: NSSortDescriptor(key: "dueDate", ascending: false),
                                                                                secondOption: NSSortDescriptor(key: "priority", ascending: false)))
        }))
        
        controller.addAction(UIAlertAction(title: "Priority", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.taskListModel.changeSortOption(sortDescriptors: SortDescriptors(firstOption: NSSortDescriptor(key: "priority", ascending: false),
                                                                                 secondOption: NSSortDescriptor(key: "dueDate", ascending: false)))
        }))
        
        
        controller.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(controller, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.taskListModel.pageTitle
        
        // TableView
        TaskCellTable.dataSource = self
        TaskCellTable.delegate = self
        TaskCellTable.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "TaskPage_TaskCell")
        
        taskListModel.delegate = self
        addLeftBarButtonWithImage(UIImage(named: "menu")!)
        
        // Open InBox
        taskListModel.changeProject(selectedProjcet: Project())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TaskListViewController: TaskListModelDelegate {
    func tasksDidChange() {
        self.navigationItem.title = self.taskListModel.pageTitle
        TaskCellTable.reloadData()
    }
    
    func insertTask(Index: Int) {
        self.TaskCellTable.insertRows(at: [IndexPath(row: Index, section: 0)], with: .bottom)
        CATransaction.setCompletionBlock({
            self.TaskCellTable.scrollToRow(at: IndexPath(row: Index, section: 0), at: UITableViewScrollPosition.middle, animated: true)
        })
        CATransaction.commit()
        tableAnimation(Index: Index)
    }
    
    func removeTask(Index: Int) {
        self.TaskCellTable.scrollToRow(at: IndexPath(row: Index, section: 0), at: UITableViewScrollPosition.none, animated: true)
        self.TaskCellTable.deleteRows(at: [IndexPath(row: Index, section: 0)], with: .bottom)
    }
    
    func updateTask(Index: Int) {
        self.TaskCellTable.scrollToRow(at: IndexPath(row: Index, section: 0), at: UITableViewScrollPosition.none, animated: true)
        self.TaskCellTable.reloadRows(at: [IndexPath(row: Index, section: 0)], with: .fade)
    }
    
    func errorDidOccur(error: Error) {
        print(error.localizedDescription)
    }
    
    func tableAnimation(Index: Int) {
        
        guard let theCell: TaskCell = self.TaskCellTable.cellForRow(at: IndexPath(row: Index, section: 0)) as? TaskCell else {
            return
        }
        
        // set cell_height = 0
        self.cellClose.append(Index)
        
        // color : initial val = blue
        theCell.backgroundColor = UIColor.blue
        
        // Animation
        UIView.animate(withDuration: 2.5, delay: 0.0, options: [], animations: {
            self.TaskCellTable.beginUpdates()
            self.cellClose.remove(at: self.cellClose.index(of: Index)!)
            self.TaskCellTable.endUpdates()
            theCell.layoutIfNeeded()
            
        }, completion: { _ in
            UIView.animate(withDuration: 2.5, delay: 0.0, options: [], animations: {
                theCell.backgroundColor = UIColor.white
                
            }, completion: nil)
        })
    }
    
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskListModel.count()
    }
    
    // return cell height (px)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.cellClose.contains(indexPath.row)) {
            return 0
        } else {
            return 100
        }
    }
    
    // create new cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskPage_TaskCell", for: indexPath) as! TaskCell
        
        let theTask = taskListModel.get(index: indexPath.row)
        
        // Configure the cell
        cell.TaskTitleLabel.text = theTask.taskName
        cell.TaskInfoLabel.text = theTask.note
        cell.AssignLabel.text = "自分"
        cell.DateLabel.text = taskListModel.dueDateToString(dueDate: theTask.dueDate)
        
        cell.defaultColor = .lightGray
        cell.firstTrigger = 0.1;
        cell.secondTrigger = 0.4
        
        
        // Set Swipe Action
        cell.setSwipeGestureWith(UIImageView(image: UIImage(named: "check")), color: UIColor.green, mode: .exit, state: .state1, completionBlock: { [weak self] (cell, state, mode) in
            
            
            if let cell = cell, let indexPath = tableView.indexPath(for: cell) {
                // Genarate Repeat Task
                if(self?.taskListModel.get(index: indexPath.row).howRepeat != 3){
                    self?.taskListModel.genRepeatask(index: indexPath.row)
                }
                
                // Send the Task to Archive
                self?.taskListModel.archive(index: indexPath.row)
            }
            //self?.TaskCellTable.reloadData()
        })
        
        cell.setSwipeGestureWith(UIImageView(image: UIImage(named: "fav")), color: UIColor.blue, mode: .exit, state: .state2, completionBlock: { [weak self] (cell, state, mode) in
            
            guard let cell = cell, let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            // Genarate Repeat Task
            if(self?.taskListModel.get(index: indexPath.row).howRepeat != 3){
                self?.taskListModel.genRepeatask(index: indexPath.row)
            }
                
            // Delete Task
            self?.taskListModel.delete(index: indexPath.row)
        })
        

        return cell
    }
    
    // cell tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // deselect
        tableView.deselectRow(at: indexPath, animated: true)
                
        // push view
        guard let TaskDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "TaskDetailViewController") as? TaskDetailViewController else {
            return
        }
        
        TaskDetailViewController.taskDetailModel = TaskDetailModel(task: taskListModel.get(index: indexPath.row))
        self.navigationController?.pushViewController(TaskDetailViewController, animated: true)
        
    }
}
