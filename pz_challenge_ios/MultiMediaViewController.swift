//
//  MultiMediaViewController.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import IJProgressView

class MultiMediaViewController: BaseViewController {

    var baseAsset: String = ""
    var medias: [Media] = []
    var currentMidia: Media?
    
    var player:AVPlayer?
    var audioPlayer:AVAudioPlayer?
    let avPlayerViewController = AVPlayerViewController()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = currentMidia?.name
                
        downloadOrStartVideo()
        mediaDelegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (player != nil && audioPlayer != nil) {
            
            audioPlayer?.stop()
            player?.pause()
            
            NotificationCenter.default.removeObserver(self)
           
            stopDownload()
            
            player = nil
        }
    }
}

// MARK: - Audio
extension MultiMediaViewController: AVAudioPlayerDelegate {
    
    public func playAudio() {
        
        let audioUrl = baseAsset + "/" + (currentMidia?.audio)!
        let url = NSURL(string: audioUrl)
        print("the url = \(url!)")
        downloadFileFromURL(url: url!)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        player.pause()
    }
    
    func downloadFileFromURL(url:NSURL){
        
        var downloadTask:URLSessionDownloadTask
        
        downloadTask = URLSession.shared.downloadTask(with: (url as URL) as URL, completionHandler: { [weak self](URL, response, error) -> Void in
            self?.play(url: URL!)
        })
        
        downloadTask.resume()
    }
    
    func play(url: URL) {
        
        do {
            
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            self.audioPlayer?.delegate = self
            
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
            
        } catch {
            
            print("AVAudioPlayer init failed")
        }
    }
}

// MARK: - Video Start and Download
extension MultiMediaViewController {
    
    public func getVideoFilePath(fileName: String) -> String {
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0] as String
        
        let fileManager = FileManager()
        
        let fullPath = path.appendingFormat("/"+fileName)
        
        let destinationURLForFile = URL(fileURLWithPath: fullPath)
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            
            return destinationURLForFile.path
            
        } else {
            
            return ""
        }
    }
    
    public func downloadOrStartVideo() {
        
        let mediaName = self.currentMidia?.video
        let mediaUrl = self.baseAsset + "/" + mediaName!
        
        let path: String? = getVideoFilePath(fileName: mediaName!)
        
        if (path?.isEmpty)! {
            
            startDownload(url: mediaUrl, assetName: mediaName!)
            
        } else {
            
            playAudio()
            playVideo(videoPath: path!)
        }
    }
    
    func playVideo(videoPath: String) {
        
        player = AVPlayer(url: URL(fileURLWithPath: videoPath))
        let playerLayerAV = AVPlayerLayer(player: player)
        
        playerLayerAV.frame = self.view.frame
        
        self.avPlayerViewController.view.frame = self.view.bounds
        self.avPlayerViewController.player = player
        self.showDetailViewController(avPlayerViewController, sender: self)
        self.view.addSubview(self.avPlayerViewController.view)
        
        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)

        player?.play()
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 0 {
            
            audioPlayer?.pause()
            
        } else if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 1 {
            
            if ( audioPlayer != nil && !(audioPlayer?.isPlaying)!) {
                
                audioPlayer?.play()
            }
        }
    }
}

extension MultiMediaViewController {
    
    func playerDidFinishPlaying(note: NSNotification){
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
}

extension MultiMediaViewController: MediaDownloadDelegate {
    
    func finishDownload(currentPath: String, assetName: String, isSucess: Bool) {
        
            IJProgressView.shared.hideProgressView()

            if (isSucess) {
                
                downloadOrStartVideo()
                
            } else {

                showAlertView(title: "Falha", message: "Não foi possível completar o download desse arquivo")
            }
    }
}

