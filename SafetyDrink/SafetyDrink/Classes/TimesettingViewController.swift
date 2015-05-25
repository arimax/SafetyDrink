//
//  TimesettingViewController.swift
//  SafetyDrink
//
//  Created by 梶嶋 佐知子 on 2015/05/23.
//  Copyright (c) 2015年 Sachiko Kajishima. All rights reserved.
//

import UIKit

class TimesettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressExecuteButton(sender: AnyObject) {
        let time:NSDate = datePicker.date
        
        var format = NSDateFormatter()
        format.locale = NSLocale(localeIdentifier: "en_US")
        format.dateFormat = "HH:mm"
        let timeString:String = format.stringFromDate(time)
        // 終電時間を登録
        let connection:Connection = Connection()
        if let delegate:AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if delegate.uuid != nil {
                let requestParameter:Dictionary<String,String> = ["time":timeString,"uuid":delegate.uuid!,"tel":"00000000000"]
                let connection:Connection = Connection()
                connection.get("http://example.com?", postData: requestParameter, getHandler: nil)
            }
        }

    }

    @IBOutlet weak var datePicker: UIDatePicker!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
