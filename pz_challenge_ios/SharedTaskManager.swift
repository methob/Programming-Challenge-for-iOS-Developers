//
//  SharedTaskManager.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 17/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit

// singleton task manager
class SharedTaskManager: NSObject, URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {

    // MARK: - Properties
    
    static let shared = SharedTaskManager()
    
    private var taskManagerQueue: [Task] = []
    
    private var backgroundSession: URLSession!
    
    private var mediaDelegate: MediaDownloadDelegate?
    
    //MARK: Background Task Delegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        
        if (error != nil) {
            
            taskManagerQueue.last?.downloadTask?.cancel()
            taskManagerQueue.removeLast()
            
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentDirectoryPath: String = path[0]
        
        self.validateDiretoryPath(documentDirectoryPath: documentDirectoryPath, location: location)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        // default
    }
    
    // MARK: Task Queue manager
    func addNewTask(asset: String, url: String, mediaDelegate: MediaDownloadDelegate) {
        
        configBackgroundTask(taskName: asset)
        
        let url = URL(string: url)!
        
        self.mediaDelegate = mediaDelegate
        
        let downloadTask = backgroundSession.downloadTask(with: url)
                
        if (!taskManagerQueue.isEmpty) {
            
            taskManagerQueue.last?.downloadTask?.suspend()
        }
    
        downloadTask.resume()
        let task = Task(downloadTask: downloadTask, assetName: asset)
        taskManagerQueue.append(task)
    }
    
    public func cancelLastTask() {
        
        if (!taskManagerQueue.isEmpty) {
            taskManagerQueue.last?.downloadTask?.cancel()
            taskManagerQueue.removeLast()
        }
    }
    
    private func configBackgroundTask(taskName: String) {
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: taskName)
        
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    private func resumeTaskInQueue() {
        
        if (self.backgroundSession != nil) {
            self.backgroundSession.finishTasksAndInvalidate();
        }
        
        if (!taskManagerQueue.isEmpty) {
            taskManagerQueue.removeLast()
        }
        
        if (!taskManagerQueue.isEmpty) {
            taskManagerQueue.last?.downloadTask?.resume()
        }
    }
    
    private func validateDiretoryPath(documentDirectoryPath: String, location: URL) {
        
        let assetName = taskManagerQueue.last?.assetName
        
        if (assetName == nil) {
            let assetName = ""
            mediaDelegate?.finishDownload(currentPath: assetName, assetName: assetName, isSucess: false)
        }
        
        resumeTaskInQueue()
        
        let fileManager = FileManager()
        
        let fullPath = documentDirectoryPath.appendingFormat("/"+assetName!)
        
        let destinationURLForFile = URL(fileURLWithPath: fullPath)
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            
            mediaDelegate?.finishDownload(currentPath: destinationURLForFile.path, assetName: assetName!, isSucess: true)
        }
            
        else {
            
            do {
                
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                
                mediaDelegate?.finishDownload(currentPath: destinationURLForFile.path, assetName: assetName!, isSucess: true)
                
            } catch {
                
                mediaDelegate?.finishDownload(currentPath: "", assetName: assetName!, isSucess: false)
            }
        }
    }
}
