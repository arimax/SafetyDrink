//
//  VoiceSettingViewController.swift
//  SafetyDrink
//
//  Created by 梶嶋 佐知子 on 2015/05/23.
//  Copyright (c) 2015年 Sachiko Kajishima. All rights reserved.
//

import UIKit

class VoiceSettingViewController: UIViewController,UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK:リターンキーが押された時
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBOutlet weak var textField: UITextField!
    // MARK:決定キーが押された時
    @IBAction func pressExecute(sender: UIBarButtonItem) {
        // メッセージを設定する
        if let sendmessage = textField.text {
            let connection:Connection = Connection()
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var param:Dictionary = Dictionary<String,String>()
            param["uuid"] = delegate.uuid
            param["message"] = sendmessage
            
            connection.get("http://example.com?", postData: param, getHandler: { (statusCode:Int, response:AnyObject, error:NSError?) -> Void in
                let filegetConnection:Connection = Connection()
                var filegetParam:Dictionary = Dictionary<String,String>()
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                filegetParam["uuid"] = delegate.uuid
                
                filegetConnection.get("http://example.com?", postData: filegetParam, getHandler: nil)
            })
            
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
