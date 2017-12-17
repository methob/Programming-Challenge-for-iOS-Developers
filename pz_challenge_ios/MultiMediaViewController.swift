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

    @IBOutlet weak var contentView: UIView!
    
    var baseAsset: String = ""
    var medias: [Media] = []
    var currentMidia: Media?
    var playButton:UIButton?

    var player:AVPlayer?
    var audioPlayer:AVPlayer?
    let avPlayerViewController = AVPlayerViewController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configNavigationItems()
        
        self.title = currentMidia?.name
                
        downloadOrStartVideo()
        mediaDelegate = self

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (player != nil) {
            
            player?.pause()
            player = nil
        }
        
        if (audioPlayer != nil){
            audioPlayer?.pause()
        }
        
        stopDownload()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private Methods
private extension MultiMediaViewController {
    
    func configNavigationItems() {
        let previousButton = UIBarButtonItem(image: UIImage(named: "ic_skip_previous"), style: .plain, target: self, action: #selector(previousTrackAction))
        let nextButton = UIBarButtonItem(image: UIImage(named: "ic_skip_next"), style: .plain, target: self, action: #selector(nextTrackAction))
        
        navigationItem.rightBarButtonItems = [nextButton, previousButton]
    }
    
    @objc func previousTrackAction(_ sender:Any) {
        
    }
    
    @objc func nextTrackAction(_ sender:Any) {
        
    }
    
}

// MARK: - Audio
extension MultiMediaViewController: AVAudioPlayerDelegate {
    
    public func playAudio() {
        
        let audioUrl = baseAsset + "/" + (currentMidia?.audio)!
        
        let url = URL(string: audioUrl)
        
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        
        audioPlayer = AVPlayer(playerItem: playerItem)

        let playerLayer=AVPlayerLayer(player: audioPlayer!)
        playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
        self.view.layer.addSublayer(playerLayer)
        audioPlayer?.play()
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        player.pause()
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
            
            IJProgressView.shared.showProgressView(view)
            startDownload(url: mediaUrl, assetName: mediaName!)
            
        } else {
            
            playAudio()
            playVideo(videoPath: path!)
        }
    }
    
    func playVideo(videoPath: String) {
        
        player = AVPlayer(url: URL(fileURLWithPath: videoPath))
        let playerLayerAV = AVPlayerLayer(player: player)
        
        playerLayerAV.frame = self.contentView.frame
        
        self.avPlayerViewController.view.frame = self.contentView.bounds
        self.avPlayerViewController.player = player
        self.showDetailViewController(avPlayerViewController, sender: self)
        
        self.contentView.addSubview(self.avPlayerViewController.view)
        self.view.addSubview(self.avPlayerViewController.view)
        
        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)

        player?.play()
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 0 {
            
            audioPlayer?.pause()
            
        } else if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 1 {
            
            if ( audioPlayer != nil && !(audioPlayer!.rate != 0 && audioPlayer!.error == nil)) {
                
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

