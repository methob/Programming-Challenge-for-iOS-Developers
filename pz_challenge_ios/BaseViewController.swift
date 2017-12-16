//
//  BaseViewController.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit


extension UIViewController {
    
    var activityIndicatorTag: Int { return 123456 }
    
    func startActivityIndicator(
        style: UIActivityIndicatorViewStyle = .gray,
        location: CGPoint? = nil) {
        
        let loc = location ?? self.view.center
        
        DispatchQueue.main.async(execute: {
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
            
            activityIndicator.tag = self.activityIndicatorTag
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        })
    }
    
    func stopActivityIndicator() {
        
        DispatchQueue.main.async(execute: {
            //Here we find the `UIActivityIndicatorView` and remove it from the view
            
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        })
    }
}

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlertErroConexao(data: Data?) {
        
        var message = "Não foi possível realizar sua solicitação, por favor verifique sua conexão e tente novamente."
        showAlertView(message: message)
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
