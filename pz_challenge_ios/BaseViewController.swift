//
//  BaseViewController.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit
import SpriteKit
import IJProgressView

protocol MediaDownloadDelegate {
    func finishDownload(currentPath: String, assetName: String, isSucess: Bool)
}

class BaseViewController: UIViewController {
    
    var mediaDelegate: MediaDownloadDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension BaseViewController {
    
    func showAlertView(title: String? = "", message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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

extension BaseViewController {
    
    public func startDownload(url: String, assetName: String) {
        
       // IJProgressView.shared.showProgressView(view)

        SharedTaskManager.shared.addNewTask(asset: assetName, url: url, mediaDelegate: self as! MediaDownloadDelegate)
    }

    func stopDownload() {
        
    }
    
    func resumeDownload() {
        
    }
}
