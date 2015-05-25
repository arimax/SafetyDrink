//
//  Connection.swift
//  SafetyDrink
//
//  Created by 梶嶋 佐知子 on 2015/05/23.
//  Copyright (c) 2015年 Sachiko Kajishima. All rights reserved.
//

import UIKit

class Connection {
    // 接続先
    
    func post(url:String,postData:Dictionary<String,String>) {
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        
        // POST用データを作成
        var postString = String()
        for (key,value) in postData {
            postString = postString + key + "=" + value + "&"
        }
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        // 通信を行う
        connect(request, handler: { (statusCode:Int, response:AnyObject?, error:NSError?) -> Void in
            if let jsonObject = response as? NSDictionary {
                // Dictionaryで返されてきた場合
                if let filePath:String = jsonObject["URL"] as? String{
                    self.getFile(filePath)
                }
            }
        })
    }
    
    func get(url:String,postData:Dictionary<String,String>,getHandler:((statusCode:Int,response:AnyObject,error:NSError?) -> Void)?){
        
        // URLを作成
        var requestURL = String(url)
        for (key,value) in postData {
            requestURL = requestURL + key + "=" + value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)! + "&"
        }
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestURL)!)
        request.HTTPMethod = "GET"
        
        // 通信を行う
        connect(request, handler: { (statusCode:Int, response:AnyObject?, error:NSError?) -> Void in
            
            if let jsonObject = response as? NSDictionary {
                // Dictionaryで返されてきた場合
                if let filePath:String = jsonObject["URL"] as? String{
                    self.getFile(filePath)
                }
                getHandler?(statusCode: statusCode,response: jsonObject,error: error)
            }
        })
        
    }
    
    func getFile(filePath:String) {
        let session:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let requestURL:NSURL = NSURL(string: filePath)!
        let filename = filePath.lastPathComponent

        let downloadTask = session.downloadTaskWithURL(requestURL, completionHandler: { (responseURL, respose, error) -> Void in
            // ファイルを保存した先をNSUserDefaultに保存しておく
            var fileURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
            fileURL = fileURL.URLByAppendingPathComponent(filename)
            let result = NSFileManager.defaultManager().copyItemAtURL(responseURL, toURL: fileURL, error: nil)
           
            NSUserDefaults.standardUserDefaults().setURL(fileURL, forKey: "filePath")
            
        })
        downloadTask.resume()
        
    }
    
    func connect(request:NSMutableURLRequest, handler:((statusCode:Int,response:AnyObject?,error:NSError?) -> Void)){
        let session:NSURLSession  = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let dataTask:NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            if error != nil {
                handler(statusCode: 400,response: nil,error: error)
            }
            if let httpResponse:NSHTTPURLResponse = response as! NSHTTPURLResponse? {
                let jsonObject:AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)!
                handler(statusCode: httpResponse.statusCode,response: jsonObject,error: error)
            }
            
        })
        
        
        // 通信開始
        dataTask.resume();
    }
    
}
