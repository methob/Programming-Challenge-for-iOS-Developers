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

class MultiMediaViewController: BaseViewController {

    var baseAsset: String = ""
    var medias: [Media] = []
    var currentMidia: Media?
    
    var player:AVPlayer?
    var audioPlayer:AVAudioPlayer?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = currentMidia?.name
        
        print("SNKAJNSJASNA")
        
        downloadOrStartVideo()
        mediaDelegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (player != nil && audioPlayer != nil) {
            player?.pause()
            
            NotificationCenter.default.removeObserver(self)

            player = nil
            audioPlayer?.stop()
        }
    }
    
}

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
            
           // playAudio()
            playVideo(videoPath: path!)
        }
    }
    
    func playVideo(videoPath: String) {
        
        player = AVPlayer(url: URL(fileURLWithPath: videoPath))
        let playerLayerAV = AVPlayerLayer(player: player)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        playerLayerAV.frame = self.view.bounds
        
        self.view.layer.addSublayer(playerLayerAV)
        
        player?.play()
    }
}

extension MultiMediaViewController {
    
    func playerDidFinishPlaying(note: NSNotification){
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
}

extension MultiMediaViewController: MediaDownloadDelegate {
    
    func finishDownload(currentPath: String, isSucess: Bool) {
            
            if (isSucess) {
                
                downloadOrStartVideo()
                
            } else {
                
                showAlertView(title: "Falha", message: "Não foi possível completar o download desse arquivo")
            }
        }
}

