//
//  LoginViewController.swift
//  SignInOutOfOzner
//
//  Created by roni on 2017/11/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        guard let username = usernameTextField.text else {
            RNNoticeAlert.showError("提示", body: "用户名不能为空")
            return
        }
        guard let password = passwordTextField.text else {
            RNNoticeAlert.showError("提示", body: "密码不能为空")
            return
        }
        
        UserDefaults.standard.set(username, forKey: UserName)
        UserDefaults.standard.set(password, forKey: Password)
        
        let userData = username.data(using: String.Encoding.utf8)
        let bUser = userData!.base64EncodedString()
        let passwordData = password.data(using: String.Encoding.utf8)
        let bPsd = passwordData!.base64EncodedString()
        
        let loginParam: [String: Any] = ["loginUserName": bUser, "password": bPsd, "udid": "A7D5EDBE-5529-1803-4DCC-45360B5F0688-1507863771-394855", "companyName": "5rWp5rO96ZuG5Zui", "registrationId":"1114a8979291e13fadf", "deviceInfo": ["platform": "ios", "version":"11.1.2", "manufactor":"apple"]] as [String : Any]
        
        self.login(login: loginParam)
    }
    
    var callback: ((_ model: LoginModel) -> ())?
    lazy var loginModel: LoginModel = {
        return LoginModel()
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "登陆"
        loginBtn.layer.masksToBounds = true
        loginBtn.layer.cornerRadius = 5.0
        
        if let name = UserDefaults.standard.object(forKey: UserName) as? String {
            usernameTextField.text = name
        }
        
        if let psd = UserDefaults.standard.object(forKey: Password) as? String {
            passwordTextField.text = psd
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func login(login: [String: Any]) {
        RNHud().showHud(nil)
        
        UserServicer.qdLogin(login, successClourue: { (result) in
            RNHud().hiddenHub()
            self.loginModel = result
            if let token = result.token {
               UserDefaults.standard.set(token, forKey: UserToken)
            }
            RNNoticeAlert.showSuccess("提示", body: "登陆成功咯", duration: 0.1)
            self.callback?(result)
            self.navigationController?.popViewController(animated: true)
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }

}
