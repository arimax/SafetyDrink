//
//  MainViewController.swift
//  SafetyDrink
//
//  Created by 梶嶋 佐知子 on 2015/05/23.
//  Copyright (c) 2015年 Sachiko Kajishima. All rights reserved.
//

import UIKit
import CoreLocation
import Security
import AVFoundation

class MainViewController: UIViewController,CLLocationManagerDelegate,HVC_Delegate {
    
    var hvcBle:HVC_BLE?                     // BLE
    var connectStatus:Int?                  // 接続情報
    var excecuteFlag:HVC_FUNCTION?          // フラグ
    var locationManager:CLLocationManager?   // ロケーションマネージャー
    var currentLocation:CLLocation?         // 現在地
    var player:AVPlayer?
    
    struct CONNECT_STATUS {
        let NotConnected:Int = 0
        let Connected:Int = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        connectStatus = 0;
        
        //HVCを作成
        hvcBle = HVC_BLE()
        hvcBle?.delegateHVC = self
        
        // ロケーションマネージャを取得
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        // 場所を取得
        //locationManager?.requestWhenInUseAuthorization()
        
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 接続を切っておく
        hvcBle?.disconnect()
    }
    @IBOutlet weak var indicatorView: UIView!
    
    // MARK: 判定ボタンを押された時の処理
    @IBAction func judge(sender: AnyObject) {
        
        if let fileURL = NSUserDefaults.standardUserDefaults().URLForKey("filePath") {
            if var player:AVPlayer = AVPlayer.playerWithURL(fileURL) as? AVPlayer {
                self.player = player
            }
        }
        // 接続済みでない場合は、接続する
        if (connectStatus == 0) {
            hvcBle?.deviceSearch()
            
            // 数秒待つ
            var semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                for i in 0..<10 {
                    sleep(1)
                }
                dispatch_semaphore_signal(semaphore)
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
             // 接続対象のデバイスを表示
            var alertController = UIAlertController(title: "デバイスを選択", message: "HVCを選んでね", preferredStyle: UIAlertControllerStyle.Alert)
            
            
            var cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
            })
            
            // アクションの追加
            alertController.addAction(cancelAction)
            
            // 接続するデバイスを表示し、選択したら接続する
            if let devices = hvcBle?.getDevices() {
                for item in devices {
                    let device:CBPeripheral = (item as? CBPeripheral)!
                    var action:UIAlertAction = UIAlertAction(title: device.name, style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                         // 接続する
                        hvcBle?.connect(device)
                    })
                    alertController.addAction(action)
                }
            }
            // アラート表示
            presentViewController(alertController, animated: true, completion:nil)
            
        } else {
            // インジケータを表示
            indicatorView.hidden = false
            
            var param:HVC_PRM = HVC_PRM()
            param.face().setMinSize(60)
            param.face().setMaxSize(480)
            hvcBle?.setParam(param)
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
    
    // MARK: HVC_Delegate
    func onConnected() {
        connectStatus = 1;
        
        // インジケータを表示
        indicatorView.hidden = false
        
        // 接続したら、データを設定
        var param:HVC_PRM = HVC_PRM()
        param.face().setMinSize(60)
        param.face().setMaxSize(480)
        hvcBle?.setParam(param)
    }
    // MARK: 接続切断したらステータスを変える
    func onDisconnected() {
        connectStatus = 0
    }
    
    // MARK: パラメータが設定された後の処理
    func onPostSetParam(err: HVC_ERRORCODE, status outStatus: UInt8) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.excecuteFlag = HVC_ACTIV_BLINK_ESTIMATION
            var res:HVC_RES  = HVC_RES()
            self.hvcBle?.Execute(self.excecuteFlag!, result: res)
        })
    }
    // MARK:実行した場合の処理
    func onPostExecute(result: HVC_RES!, errcode err: HVC_ERRORCODE, status outStatus: UInt8) {
        connectStatus = 2
        // メツムリ情報を取得
        var detected:Bool = false
        var warning:Bool = false
        
        if err.value != HVC_NORMAL.value || outStatus != 0 {
            // 正常終了だった場合以外は再度取得
           faceDetect()
            return
        }
        
        if result.executedFunc().value & HVC_ACTIV_BLINK_ESTIMATION.value == 0 {
            // 正常終了以外はもう一度
            faceDetect()
            return
        }
        
        if result.sizeFace() == 0 {
            // 顔を1件も取得していない場合
            faceDetect()
            return
        }
        
        print(result.sizeFace())
                
        // 顔の数だけ取得
        for i in 0 ..< result.sizeFace() {
            // インジケータを表示
            indicatorView.hidden = true
            let faceDetect:FaceResult = result.face(i)
            if faceDetect.blink().ratioR() > 600 && faceDetect.blink().ratioL() > 600 {
                print("ねてる \(faceDetect.blink().ratioR()) \(faceDetect.blink().ratioL())")
                detected = true
            } else if faceDetect.blink().ratioL() > 250 && faceDetect.blink().ratioR() > 250 {
                warning = true
            } else {
                print("まだ大丈夫 \(faceDetect.blink().ratioR()) \(faceDetect.blink().ratioL())")
            }
        }
        
        if detected  {
            // 音を鳴らす
            self.player?.play()

            // ねている判定だったらアラート出す
            let alertController:UIAlertController = UIAlertController(title: "判定結果", message: "ねてます", preferredStyle: .Alert)
            let executeAction:UIAlertAction = UIAlertAction(title: "帰る", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                
                if let location = self.currentLocation {
                    // 位置情報を取得済みだったら、終電検索
                }                                           
                
            })
            let cancelAction:UIAlertAction = UIAlertAction(title: "まだ飲む", style: UIAlertActionStyle.Cancel, handler: {(action:UIAlertAction!) -> Void in
                
                if let location = self.currentLocation {
                // 位置情報を取得済みだったら、終電検索
                
                } else if let time: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("time"){
                    
                }
            
            })
            // Actionを追加
            alertController.addAction(executeAction)
            alertController.addAction(cancelAction)
            
            // アラートを表示する
            presentViewController(alertController, animated: true, completion: nil)
            
        } else if warning {
            // 水飲んでね表示を出す
            let alertController:UIAlertController = UIAlertController(title: "判定結果", message: "水飲んでね", preferredStyle: .Alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            // アラートを表示する
            presentViewController(alertController,animated:true,completion:nil)
            
        } else {
            // まだ大丈夫表示を出す
            let alertController:UIAlertController = UIAlertController(title: "判定結果", message: "まだ大丈夫", preferredStyle: .Alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            // アラートを表示する
            presentViewController(alertController,animated:true,completion:nil)
        }
    }
    
    func faceDetect() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var res:HVC_RES  = HVC_RES()
            self.hvcBle?.Execute(self.excecuteFlag!, result: res)
        })
    }
    
    // MARK: LocationDelegate
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
        
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if locations.count > 0 {
            currentLocation = locations.first as? CLLocation
        }
        
        // 位置情報取得をやめておく
        locationManager?.stopUpdatingLocation()
    }
}
