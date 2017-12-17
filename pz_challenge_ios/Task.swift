//
//  Task.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 17/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit

class Task: NSObject {

    var downloadTask: URLSessionDownloadTask?
    var assetName: String?

    init(downloadTask: URLSessionDownloadTask, assetName: String) {
        self.downloadTask = downloadTask
        self.assetName = assetName
    }
    
}
