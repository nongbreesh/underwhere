//
//  JsonHelper.swift
//  Quam
//
//  Created by Breeshy Sama on 12/4/2557 BE.
//  Copyright (c) 2557 Breeshy Sama. All rights reserved.
//

import Foundation

func HTTPsendRequest(request: NSMutableURLRequest,
    callback: (String, String?) -> Void) {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(
            request,
            completionHandler: {
                data, response, error in
                if error != nil {
                    callback("", error.localizedDescription)
                } else {
                    callback(
                        NSString(data: data, encoding: NSUTF8StringEncoding)! as String,
                        nil
                    )
                }
        })
        
        task.resume()
}

func HTTPGet(url: String, callback: (String, String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    HTTPsendRequest(request, callback)
}

func parseJSON(inputData: NSData) -> NSDictionary{
    var error: NSError?
    let boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: NSErrorPointer()) as! NSDictionary
    return boardsDictionary
}
