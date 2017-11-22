//
//  UserServicer.swift
//  SignInOutOfOzner
//
//  Created by roni on 2017/11/21.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct UserServicer {
    
    
    /// 登陆
    ///
    /// - Parameters:
    ///   - parameter: <#parameter description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func qdLogin(_ parameter: [String: Any], successClourue: ((LoginModel) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        let _ = RNNetworkManager.shared.post(AppLogin, parameters: parameter, successClourue: { (result) in
            
            let data =  result["data"]
            
            var model = LoginModel()
            model.token = data["accessToken"].stringValue
            model.server = data["cpServer"].stringValue
            
            successClourue?(model)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 签到页面信息
    ///
    /// - Parameters:
    ///   - parameter: <#parameter description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getShowInfo(_ parameter: [String: Any], successClourue: ((ShowModel) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        let _ = RNNetworkManager.shared.get(ShowInfo, parameters: parameter, successClourue: { (result) in
            
            let data =  result["data"]
            
            var model = ShowModel()
            model.coWorkOff = data["coWorkOff"].stringValue
            model.currentDate = data["currentDate"].stringValue
            model.currentDateDesc = data["currentDateDesc"].stringValue
            model.currentTime = data["currentTime"].stringValue
            model.timeWorkOn = data["timeWorkOn"].stringValue
            model.timeWorkOff = data["timeWorkOff"].stringValue
            model.welcome = data["welcome"].stringValue
            model.workingTimeDesc = data["workingTimeDesc"].stringValue
            
            var sArray = [schedulesModel]()
            let schedules = data["schedules"].array
            if let array = schedules {
                for item in array {
                    var sModel = schedulesModel()
                    sModel.attCoSol = item["attCoSol"].stringValue
                    sModel.enableOffEndTime = item["enableOffEndTime"].stringValue
                    sModel.enableOnEndTime = item["enableOnEndTime"].stringValue
                    sModel.enableOffStartTime = item["enableOffStartTime"].stringValue
                    sModel.enableOnStartTime = item["enableOnStartTime"].stringValue
                    sModel.scheduleId = item["scheduleId"].stringValue
                    sModel.scheduleName = item["scheduleName"].stringValue
                    sModel.workOnTime = item["workOnTime"].stringValue
                    sArray.append(sModel)
                }
            }
            model.schedules = sArray
            
            successClourue?(model)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 签退
    ///
    /// - Parameters:
    ///   - parameter: <#parameter description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func signOut(_ parameter: [String: Any], token: String, successClourue: ((TimeModel) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        let url = SignOut + "?" + "accessToken:\(token)"
        let _ = RNNetworkManager.shared.post(url, parameters: parameter, isContentType: true, encoding: URLEncoding.httpBody, successClourue: { (result) in
            
            let data =  result["data"]
            
            var model = TimeModel()
            model.date = data["coDate"].stringValue
            model.time = data["coTime"].stringValue
            
            successClourue?(model)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
}
