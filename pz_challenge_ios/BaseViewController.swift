//
//  BaseViewController.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit

protocol MediaDownloadDelegate {
    func finishDownload(currentPath: String, isSucess: Bool)
}

class BaseViewController: UIViewController {
    
    var progressView: UIProgressView!
    var assetName: String?
    
    var mediaDelegate: MediaDownloadDelegate?
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
}

extension BaseViewController {
    
    func showProgressView() {
        
        let loc = self.view.center
        
        DispatchQueue.main.async(execute: {
            
            self.progressView = UIProgressView()
            
            self.progressView.tag = 123456
            self.progressView.center = loc
            self.progressView.setProgress(0.0, animated: true)
            
            self.view.addSubview(self.progressView)
        })
    }
    
    func showAlertView(title: String? = "", message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {    (action:UIAlertAction!) in
            print("you have pressed the Cancel button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension BaseViewController {
    
    func validateDiretoryPath(documentDirectoryPath: String, location: URL) {
        
        let fileManager = FileManager()
                
        let fullPath = documentDirectoryPath.appendingFormat("/"+assetName!)
        
        let destinationURLForFile = URL(fileURLWithPath: fullPath)
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            
            print("ja tem")
            mediaDelegate?.finishDownload(currentPath: destinationURLForFile.path, isSucess: true)
        }
            
        else {
            
            do {
                
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                
                mediaDelegate?.finishDownload(currentPath: destinationURLForFile.path, isSucess: true)
                
            } catch {
                
                mediaDelegate?.finishDownload(currentPath: "", isSucess: false)
            }
        }
        
        stopActivityIndicator()
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
        print("SUAHSUAHSUAHSAU")
        
    }
}

extension BaseViewController {
    
    func startActivityIndicator(
        style: UIActivityIndicatorViewStyle = .gray,
        location: CGPoint? = nil) {
        
        let loc = location ?? self.view.center
        
        DispatchQueue.main.async(execute: {
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
            
            activityIndicator.tag = 123456
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        })
    }
    
    func stopActivityIndicator() {
        
        DispatchQueue.main.async(execute: {
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == 123456}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        })
    }
}

extension BaseViewController: URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {
    
    public func startDownload(url: String, assetName: String) {
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        
        
        let url = URL(string: url)!
        
        self.assetName = assetName
        
        startActivityIndicator()
            
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    func stopDownload() {
        if downloadTask != nil{
            downloadTask.suspend()
        }
    }
    
    func resumoDownload() {
        if downloadTask != nil{
            downloadTask.resume()
        }
    }
}
