//
//  ViewController.swift
//  SignInOutOfOzner
//
//  Created by roni on 2017/11/21.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    
    @IBAction func clickAction(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            // 登陆
            login()
            break
        case 200:
            // 进入签到界面
            showInfo()
            break
        case 300:
            // 签到
            signIn()
            break
        case 400:
            // 签退
            signOut()
            break
        default:
            break
        }
    }
    
    // 登陆参数 -  当前默认 : zwx --->  不同的人 "loginUserName": "6YOR5paH56Wl", "password": "MzI4OTI4" 两个字段不同
    var loginParam: [String: Any] = ["loginUserName": "6YOR5paH56Wl", "password": "MzI4OTI4", "udid": "A7D5EDBE-5529-1803-4DCC-45360B5F0688-1507863771-394855", "companyName": "5rWp5rO96ZuG5Zui", "registrationId":"1114a8979291e13fadf", "deviceInfo": ["platform": "ios", "version":"11.1.2", "manufactor":"apple"]] as [String : Any]
    var showString: String = ""
    lazy var loginModel: LoginModel = {
        return LoginModel()
    }()
    lazy var showModel: ShowModel = {
        return ShowModel()
    }()
    lazy var timeModel: TimeModel = {
        return TimeModel()
    }()
    lazy var signoutParams: [String: Any] = {
        return [String: Any]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "zwx"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 字典转 jsonString
    func dicToJsonString(_ dic: [String: Any]) -> String?{
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        guard let haveData = data else{
            return nil
        }
        var strJson = String(data: haveData, encoding: String.Encoding.utf8)
        
        strJson = strJson?.replacingOccurrences(of: "\n", with: "")
        //strJson = strJson?.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        return strJson
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectionViewController = segue.destination as! SelectionController
        
        if segue.identifier == "Selection" {
            
            // 不写了
        }
    }

}

extension ViewController {
    func login() {
        RNHud().showHud(nil)
        
        UserServicer.qdLogin(loginParam, successClourue: { (result) in
            RNHud().hiddenHub()
            self.loginModel = result
            
            DispatchQueue.main.async {
                self.showString = "token: \(result.token!)\nserver: \(result.server!)"
                self.textView.text = self.showString
            }
            RNNoticeAlert.showSuccess("提示", body: "登陆成功", duration: 0.2)
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func showInfo() {
        
        guard let token = loginModel.token else {
            RNNoticeAlert.showError("提示", body: "token为空")
            return
        }
        let param = ["accessToken": token] as [String : Any]
        RNHud().showHud(nil)
        UserServicer.getShowInfo(param, successClourue: { (result) in
            RNHud().hiddenHub()
            self.showModel = result
            DispatchQueue.main.async {
                self.showString += "\n=================================\n"
                self.showString += "date: \(result.currentDate!)\ntime: \(result.currentTime!)\nworkingTimeDesc: \(result.workingTimeDesc!)\nworkOnTime: \(result.schedules!.last!.workOnTime!)\nscheduleId: \(result.schedules!.last!.scheduleId!)\nscheduleName: \(result.schedules!.last!.scheduleName!)"
                self.textView.text = self.showString
            }
             RNNoticeAlert.showSuccess("提示", body: "获取信息成功", duration: 0.2)
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func signIn() {
        guard let token = loginModel.token else {
            RNNoticeAlert.showError("提示", body: "token为空")
            return
        }
        mergeParams(tag: 0)
        RNHud().showHud(nil)
        UserServicer.signOut(signoutParams, token: token, successClourue: { (result) in
            RNHud().hiddenHub()
            self.timeModel = result
            DispatchQueue.main.async {
                self.showString += "\n=================================\n"
                self.showString += "date: \(result.date!)\ntime: \(result.time!)"
                self.textView.text = self.showString
            }
            self.shouMsg(leftString: "Work", rightString: "Sleep", contentString: "Work or sleep? That's a question - \(result.date ?? "") \(result.time ?? "")")
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func signOut() {
        guard let token = loginModel.token else {
            RNNoticeAlert.showError("提示", body: "token为空")
            return
        }
        mergeParams(tag: 1)
        RNHud().showHud(nil)
        UserServicer.signOut(signoutParams, token: token, successClourue: { (result) in
            RNHud().hiddenHub()
            self.timeModel = result
            DispatchQueue.main.async {
                self.showString += "\n=================================\n"
                self.showString += "date: \(result.date!)\ntime: \(result.time!)"
                self.textView.text = self.showString
            }
            self.shouMsg(leftString: "好的", rightString: "腿被打断了", contentString: "下班了还不快跑 - \(result.date ?? "") \(result.time ?? "")")
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func mergeParams(tag: Int) {
    
        guard let token = loginModel.token else {
            RNNoticeAlert.showError("提示", body: "token为空")
            return
        }
        guard let schedule = showModel.schedules?.last else {
            RNNoticeAlert.showError("提示", body: "schedule为空")
            return
        }
        
        let sp: [String: String] = ["attCoSol": schedule.attCoSol ?? "", "enableOffEndTime": schedule.enableOffEndTime ?? "", "enableOffStartTime": schedule.enableOffStartTime ?? "", "enableOnEndTime": schedule.enableOnEndTime ?? "", "enableOnStartTime": schedule.enableOnStartTime ?? "", "scheduleId": schedule.scheduleId ?? "", "scheduleName": schedule.scheduleName ?? "", "workOnTime": schedule.workOnTime ?? ""]
        let lp: [String: String] = ["latitude": "31.24179053588886", "longitude": "121.60099938523173", "success": "1"]
        
        var fp: [String: String] = ["onOrOff": "off", "attCoSol": "gps"]
        switch tag {
        case 0: // 签到
            fp = ["onOrOff": "on", "attCoSol": "gps"]
        case 1: //签退
            fp = ["onOrOff": "off", "attCoSol": "gps"]
        default:
            break
        }
        // "accessToken": token
        
//        let s = dicToJsonString(fp)
//        guard let info = s else{
//            RNNoticeAlert.showError("提示", body: "json串生成失败")
//            return
//        }
        
        var ss: [String: Any] =  ["scheduleInfo": sp, "gspInfoVO": lp]
//        for item in lp {
//            sp[item.key] = item.value
//        }
        for item in fp{
            ss[item.key] = item.value
        }
        
        signoutParams = ["checkout": dicToJsonString(ss)!]  // "accessToken": token,
        
    }
    
    func shouMsg(leftString: String, rightString: String, contentString: String) {
        
        let alert = UIAlertController(title: "浩泽沙币", message: contentString, preferredStyle: .alert)
        let deletaButton = UIAlertAction(title: leftString, style: .default, handler: nil)
        let cancelButton = UIAlertAction(title: rightString, style: .destructive,  handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(deletaButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}
