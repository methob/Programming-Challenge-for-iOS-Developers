//
//  SharedTaskManager.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 17/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit

class SharedTaskManager: NSObject, URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {

    // MARK: - Properties
    
    static let shared = SharedTaskManager()
    
    // MARK: -
    
    private var taskManagerQueue: [Task] = []
    
    private var backgroundSession: URLSession!
    
    private var mediaDelegate: MediaDownloadDelegate?
    
    private func resumeTaskInQueue() {
        
        if (self.backgroundSession != nil) {
            self.backgroundSession.finishTasksAndInvalidate();
        }

        taskManagerQueue.removeLast()

        if (!taskManagerQueue.isEmpty) {
            taskManagerQueue.last?.downloadTask?.resume()
        }
    }
    
    private func validateDiretoryPath(documentDirectoryPath: String, location: URL) {
        
        let assetName = taskManagerQueue.last?.assetName
        
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
    
    //MARK: URLSessionTaskDelegate
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
    }
    
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
    
    private func configBackgroundTask(taskName: String) {
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: taskName)
        
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }
}
