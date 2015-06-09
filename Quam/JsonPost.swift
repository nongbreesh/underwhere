//
//  JsonPost.swift
//  Quam
//
//  Created by Breeshy Sama on 3/23/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import Foundation

func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
    let session = NSURLSession.sharedSession()
    let url = NSURL(string:url)
    let request = NSMutableURLRequest(URL: url!)
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.HTTPMethod = "POST"
    var err: NSError?

        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(), error: NSErrorPointer()) 

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = session.dataTaskWithRequest(request) {
        data, response, error in

        if (error != nil) {
            print("error submitting request: \(error)")
            return
        }

        // handle the data of the successful response here

       var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary

    }
    
    
    task.resume()
}