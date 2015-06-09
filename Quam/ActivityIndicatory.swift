//
//  ActivityIndicatory.swift
//  Quam
//
//  Created by Breeshy Sama on 1/8/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit
var container: UIView = UIView()

var messageFrame = UIView()
var activityIndicator = UIActivityIndicatorView()
var strLabel = UILabel()

func progressBarDisplayer(view: UIView ,msg:String,indicator:Bool ) {
    container.frame = view.frame
    container.center = view.center
     container.backgroundColor = colorize(0xffffff, alpha: 0.3)
    strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
    strLabel.text = msg
    strLabel.textColor = UIColor.whiteColor()
    messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
    messageFrame.layer.cornerRadius = 15
    messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
    if indicator {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        messageFrame.addSubview(activityIndicator)
    }
     container.addSubview(activityIndicator)
    messageFrame.addSubview(container)
    view.addSubview(messageFrame)
}


func ActivityIndicatory(uiView: UIView , rs:Bool,hidebg:Bool) {
    if rs == true{
        container.frame = uiView.frame
        container.center = uiView.center

        if hidebg == true{
             container.backgroundColor = colorize(0x000000, alpha: 1)
        }
        else
        {
            container.backgroundColor = colorize(0xffffff, alpha: 0.3)
        }

        let loadingView: UIView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = colorize(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    else{
        container.removeFromSuperview()
    }
    
}
