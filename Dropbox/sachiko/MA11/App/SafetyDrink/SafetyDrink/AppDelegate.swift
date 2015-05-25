//
//  AppDelegate.swift
//  SafetyDrink
//
//  Created by 梶嶋 佐知子 on 2015/05/23.
//  Copyright (c) 2015年 Sachiko Kajishima. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var uuid:String?              // UUID(キーチェーンにあればそこから取得。なければ生成)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Keychain からUUIDを取得
        let key:String = "UUID"
        let query:NSDictionary = NSDictionary(objectsAndKeys: kSecClassGenericPassword,kSecClass,key,kSecAttrAccount,kCFBooleanTrue,kSecReturnData,kSecMatchLimitOne,kSecMatchLimit)
        
        var dataTypeRef :Unmanaged<AnyObject>?
        let error:OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        if error == noErr {
            let opaque = dataTypeRef?.toOpaque()
            if let op = opaque {
                let receivedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
                let string:NSString = NSString(data: receivedData, encoding: NSUTF8StringEncoding)!
                self.uuid = string as String!
                
            }
        } else if error == errSecItemNotFound {
            //　ない場合は新規作成
            let nsstringUUID:NSString = NSUUID().UUIDString
            var addTypeRef :Unmanaged<AnyObject>?
            let setQuery:NSDictionary = NSDictionary(objectsAndKeys: kSecClassGenericPassword,kSecClass,key,kSecAttrAccount,nsstringUUID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!,kSecValueData)
            let error:OSStatus = SecItemAdd(setQuery, nil)
            self.uuid = nsstringUUID as String!
            
        }

        // 音声をダウンロードしておく
        var connection:Connection = Connection()
        var param:Dictionary = Dictionary<String,String>()
        //param["uuid"] = self.uuid
        
        connection.get("http://example.com?",postData:param, getHandler: nil)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func checkTime() {

    }

}

