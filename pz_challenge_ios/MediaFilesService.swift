//
//  MediaFilesService.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper


@objc protocol MediaFilesServiceDelegate {
    
    @objc optional func requestMediaFilesSuccessful(dataAssets: DataAssets?)
    @objc optional func requestMediaFilesFailed(data: Data?)
}


class MediaFilesService: NSObject {
    
    let delegate: MediaFilesServiceDelegate
    
    init(delegate: MediaFilesServiceDelegate) {

        self.delegate = delegate
    }

    func requestMediaFiles() {
        
        let url = baseUrl + "assets.json"
        
        Alamofire.request(url, method: .get).responseObject { (response: DataResponse<DataAssets>) in
            
            switch response.result {
                case .success:
                    self.delegate.requestMediaFilesSuccessful!(dataAssets: response.result.value)
                    break
                case .failure:
                    self.delegate.requestMediaFilesFailed!(data: response.data)
                    break
            }
        }
    }
}

