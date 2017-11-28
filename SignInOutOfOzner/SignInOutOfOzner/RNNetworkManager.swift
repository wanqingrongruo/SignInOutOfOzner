//
//  RNNetworkManager.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/27.
//  Copyright © 2017年 roni. All rights reserved.
//


/// ## 网络 Manager

import Foundation
import Alamofire
import SwiftyJSON

struct RNNetworkManager {
    
    init() {
        
    }
    
    fileprivate let baseUrl = BASEURL // 服务器地址
    
    static var shared = RNNetworkManager() // NetWorkManager, 通过他进行网络请求
    
    
    // TO DO: 升级 swift 4 后将 fileprivate 改为 private
    // 默认 manager
    fileprivate lazy var defaultManager: SessionManager = {
        
        let defHeaders  = SessionManager.defaultHTTPHeaders
        let conf = URLSessionConfiguration.default
        conf.httpAdditionalHeaders = defHeaders
        conf.timeoutIntervalForRequest = 60 // 请求过期时间
        
        let manager = SessionManager(configuration: conf)
        
        return manager
    }()
    
    // 后台下载 manager
    fileprivate lazy var backgroundManager: SessionManager = {
        
        // 请求头 - 可配置
        let defHeaders  = SessionManager.defaultHTTPHeaders
        let conf = URLSessionConfiguration.background(withIdentifier: "com.ozner.specialHoyoservicer")
        conf.httpAdditionalHeaders = defHeaders
        conf.timeoutIntervalForRequest = 60
        
        let manager = SessionManager(configuration: conf)
        
        return manager
    }()
    
    // 临时会话 manager
    fileprivate lazy var ephemeralManager: SessionManager = {
        let defHeaders  = SessionManager.defaultHTTPHeaders
        let conf = URLSessionConfiguration.ephemeral
        conf.httpAdditionalHeaders = defHeaders
        conf.timeoutIntervalForRequest = 60
        
        let manager = SessionManager(configuration: conf)
        
        return manager
        
    }()
    
    
    fileprivate var userToken: String? {
        
//        if let token = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) {
//            return token as? String
//        }
        return nil
    }
}


//MARK: - GET

extension RNNetworkManager {
    
    
    /// get
    ///
    /// - Parameters:
    ///   - path: 请求路径
    ///   - parameters: 参数字典
    ///   - isToken: 是否需要 token, 默认需要
    ///   - successClourue:  成功回调
    ///   - failureClousure: 失败回调  --- 错误码处除了后台返回的, 其他都是写死的,方便定位错误
    /// - Returns: DataRequest
    mutating func get(_ path: String, parameters: [String: Any]?, isToken: Bool = false, isContentType: Bool = false,encoding: ParameterEncoding = URLEncoding.default,successClourue: ((JSON) -> Void)?, failureClousure: ((String, Int) -> Void)?) -> DataRequest? {
        
        return requestAction(.get, path: path, parameters:parameters, isToken:isToken, isContentType: isContentType, successClourue: successClourue,failureClousure:failureClousure)
    }
    
}


//MARK: - POST

extension RNNetworkManager {
    
    /// post
    ///
    /// - Parameters:
    ///   - path: 请求路径
    ///   - parameters: 参数字典
    ///   - isToken: 是否需要 token,  默认需要
    ///   - successClourue:  成功回调
    ///   - failureClousure: 失败回调  --- 错误码处除了后台返回的, 其他都是写死的,方便定位错误
    /// - Returns: DataRequest
    @discardableResult
    mutating func post(_ path: String, parameters: [String: Any]?, isToken: Bool = false, isContentType: Bool = false, encoding: ParameterEncoding = URLEncoding.default, successClourue: ((JSON) -> Void)?, failureClousure: ((String, Int) -> Void)?) -> DataRequest? {
        
        return requestAction(.post, path: path, parameters:parameters, isToken:isToken,isContentType: isContentType, successClourue: successClourue,failureClousure:failureClousure)
    }
    
}


//MARK: - Upload

extension RNNetworkManager {
    
    
    
    /// 上传
    ///
    /// - Parameters:
    ///   - path: 路径
    ///   - parameters: 参数字典
    ///   - isToken: 是否需要 token,  默认需要
    ///   - multipartFormData: 模拟表单 -- 如果我们上传多个文件，多次调用multipartFormData.appendBodyPart就可以了
    ///   - progressClousure: 进度回调
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调  --- 错误码处除了后台返回的, 其他都是写死的,方便定位错误
    mutating func upload(_ path: String, parameters: [String: Any]?, isToken: Bool = true, multipartFormData: @escaping (MultipartFormData) -> Void, progressClousure: ((Progress) -> Void)?, successClourue: ((JSON) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let url = self.baseUrl + path
        
        if url == "" {
            let error = "请求地址不能为空"
            failureClousure?(error, 100000000)
            return
        }
        
        // 合并参数
        var headers = SessionManager.defaultHTTPHeaders
        
        if let params = parameters {
            for (key, value) in params {
                headers[key] = value as? String
            }
        }
        
        if isToken {
            
            if let token = userToken {
                headers["usertoken"] = token
            }
            
        }
        
        defaultManager.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: headers) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(queue: DispatchQueue.main, closure: { (progress) in
                    progressClousure?(progress) // 进度回调
                }).responseData { (data) in
                    
                    //                    guard let _ = data.result.value else{
                    //                        if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
                    //                            failureClousure?("网络状态异常", 404)
                    //                        }else{
                    //                            failureClousure?("未知原因导致请求结果为 nil", 405)
                    //                        }
                    //                        return
                    //                    }
                    
                    switch data.result {
                    case .success(let data):
                        let object = try! JSON(data: data)
                        
                        let state = object["state"].intValue
                        if state >= successCode {
                            successClourue?(object)
                        }
                        else{
                            let msg = object["msg"].stringValue
                            failureClousure?(msg , state)
                        }
                        
                    case .failure(let error):
                        if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
                            failureClousure?("网络状态异常", 404)
                        }else{
                            failureClousure?(error.localizedDescription, 405)
                        }
                        
                    }
                    
                }
            case .failure(let error):
                if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
                    failureClousure?("网络状态异常", 404)
                }else{
                    let erro1 = error as NSError
                    var errorDes: String = error.localizedDescription
                    switch erro1.code { // 错误码:http://www.jianshu.com/p/82a2125bda76
                    case -1001:
                        errorDes = "网络请求超时"
                        failureClousure?(errorDes, erro1.code)
                    case -1200:
                        errorDes = "网络连接失败"
                        failureClousure?(errorDes, erro1.code)
                    default:
                        failureClousure?(errorDes,5555555)
                    }
                    
                }

                
            }
        }
        
        
    }
}







//MARK: - download

extension RNNetworkManager {
    
    
    /// 下载
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - path: 路径
    ///   - parameters: 参数字典
    ///   - isToken:  是否需要token,  默认不需要
    ///   - destination: 指定存储位置
    ///   - progressClousure: 下载进度回调
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调 --- 错误码处除了后台返回的, 其他都是写死的,方便定位错误
    /*关于 destination
     Alamofire会把文件下载到App默认的tmp目录，之后，它需要调用一个Closure来获得从tmp目录把文件Copy走的位置，而指定这个位置，就是destination参数的作用
     eg:
     let dest: Request.DownloadFileDestination = { temporaryURL, response in //response - 表示服务器返回的HTTP Response
     print(temporaryURL)  // 它是一个NSURL对象，表示Alamofire保存下载的临时文件的完整路径
     
     let pathComponent = response.suggestedFilename // 获取了要下载的文件名，Alamofire的suggestedFilename默认会使用下载URL中的最后一段做为文件名，当然，你也可以指定任意一个自己需要的名字
     let episodeUrl =
     self.episodesDirUrl.URLByAppendingPathComponent(pathComponent!) // 拼接
     
     // 如果episodes目录存在同名文件，我们要先删掉它，否则Alamofire会在移动临时文件时返回错误
     if episodeUrl.checkResourceIsReachableAndReturnError(nil) {
     print("Clear the previous existing file.")
     
     let fm = NSFileManager.defaultManager()
     
     try! fm.removeItemAtURL(episodeUrl)
     }
     
     return episodeUrl
     }
     */
    mutating func download(_ method: HTTPMethod, path: String, parameters: [String: Any]?, isToken: Bool = false, destination: DownloadRequest.DownloadFileDestination?, progressClousure: ((Progress) -> Void)?, successClourue: ((JSON) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let url = self.baseUrl + path
        
        if url == "" {
            let error = "请求地址不能为空"
            failureClousure?( error, 100000000)
            return
        }
        
        // 合并参数
        var param = parameters != nil ? parameters :  [String: Any]()
        if isToken {
            
            if let _ = param, let token = userToken {
                param!["usertoken"] = token
            }
            
        }
       
        
        defaultManager.download(url, method: method, parameters: param, encoding: URLEncoding.default, to: destination).downloadProgress { (progress) in
            progressClousure?(progress) // 进度回调
            }.responseData { (data) in
                
                //                guard let _ = data.result.value else{
                //                    if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
                //                        failureClousure?("网络状态异常", 404)
                //                    }else{
                //                        failureClousure?("未知原因导致请求结果为 nil", 405)
                //                    }
                //                    return
                //                }
                
                switch data.result {
                case .success(let data):
                    
                    let object = try! JSON(data: data)
                    
                    
                    let state = object["state"].intValue
                    if state >= successCode {
                        
                        successClourue?(object)
                    }
                    
                    else{
                        
                        let msg = object["msg"].stringValue
                        failureClousure?(msg , state)
                    }
                    
                case .failure(let error):
                    
                    if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
                        failureClousure?("网络状态异常", 404)
                    }else{
                        
                        let erro1 = error as NSError
                        var errorDes: String = error.localizedDescription
                        switch erro1.code { // 错误码:http://www.jianshu.com/p/82a2125bda76
                        case -1001:
                            errorDes = "网络请求超时"
                            failureClousure?(errorDes, erro1.code)
                        case -1200:
                            errorDes = "网络连接失败"
                            failureClousure?(errorDes, erro1.code)
                        default:
                            failureClousure?(errorDes,5555555)
                        }

                        
                    }
                    
                }
                
        }
        
    }
    
}


//MARK: - private
extension RNNetworkManager {
    
    fileprivate mutating func requestAction(_ method: HTTPMethod, path: String, parameters: [String: Any]?, isToken: Bool, isContentType: Bool, encoding: ParameterEncoding = URLEncoding.default, successClourue: ((JSON) -> Void)?, failureClousure: ((String, Int) -> Void)?) -> DataRequest?{
        
        let url = path
        
      //  print("path = \(path)")
        
        if url == "" {
            let error = "请求地址不能为空"
            failureClousure?( error, 100000000)
            return nil
        }
        
        // 合并参数
        
        var param = parameters != nil ? parameters :  [String: Any]()
        if isToken {
            
            if let _ = param, let token = userToken {
                param!["usertoken"] = token
            }
            
        }
        
       
        var headers = SessionManager.defaultHTTPHeaders
        if isContentType {
            headers["Content-Type"] = "text/html;charset=UTF-8" //text/html;charset=utf-8"
            
            let myUrl = URL(string: url)!
            
            var urlRequest: URLRequest = URLRequest(url: myUrl, timeoutInterval: 60)
            
            let jsonStr = parameters?["checkout"] as? String
            let postData = jsonStr?.data(using: String.Encoding.utf8)!
            
            urlRequest.httpBody = postData
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            urlRequest.allHTTPHeaderFields = headers
            
            return  defaultManager.request(urlRequest).responseData { (data) in
                switch data.result {
                case .success(let data):
                    
                    let object =  try? JSON(data: data)
                    
                    let errorCode =  object?["errorCode"].intValue ?? 10000
                    if errorCode == 10000 {
                        let errorText = object?["errorText"].stringValue ?? "你妈炸了"
                        failureClousure?(errorText , errorCode)
                        return
                    }
                    
                    let state = object?["responseCode"].intValue ?? 0
                    if state == successCode {
                        
                        if object == nil {
                            let d = "ssss"
                            let da = d.data(using: String.Encoding.utf8)!
                            let daa = try! JSON(data: da)
                            successClourue?(daa)
                            
                        }else{
                            successClourue?(object!)
                        }
                        
                    }
                    else{
                        
                        let msg = object?["responseText"].stringValue ?? "你猜猜看"
                        if msg == "" {
                            failureClousure?("错误信息为空" , state)
                        }else{
                            failureClousure?(msg , state)
                        }
                        
                    }
                case .failure(let error):
                    
                    if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
                        failureClousure?("网络状态异常", 404)
                    }else{
                        
                        let erro1 = error as NSError
                        var errorDes: String = error.localizedDescription
                        switch erro1.code { // 错误码:http://www.jianshu.com/p/82a2125bda76
                        case -1001:
                            errorDes = "网络请求超时"
                            failureClousure?(errorDes, erro1.code)
                        case -1200:
                            errorDes = "网络连接失败"
                            failureClousure?(errorDes, erro1.code)
                        default:
                            failureClousure?(errorDes,5555555)
                        }
                        
                    }
                    
                }
            }
        }
        
        
        
      
        
        return defaultManager.request(url, method: method, parameters: param, encoding: encoding, headers: headers).responseData { (data) in
            
            switch data.result {
            case .success(let data):
                
                let object =  try? JSON(data: data)
                
                let errorCode =  object?["errorCode"].intValue ?? 10000
                if errorCode == 10000 {
                    let errorText = object?["errorText"].stringValue ?? "你妈炸了"
                    failureClousure?(errorText , errorCode)
                    return
                }
                
                let state = object?["responseCode"].intValue ?? 0
                if state == successCode {
                    
                    if object == nil {
                        let d = "ssss"
                        let da = d.data(using: String.Encoding.utf8)!
                        let daa = try! JSON(data: da)
                        successClourue?(daa)
                        
                    }else{
                        successClourue?(object!)
                    }
                   
                }
                else{
                    
                    let msg = object?["responseText"].stringValue ?? "你猜猜看"
                    if msg == "" {
                        failureClousure?("错误信息为空" , state)
                    }else{
                        failureClousure?(msg , state)
                    }
                    
                }
                
            case .failure(let error):
                
                if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
                    failureClousure?("网络状态异常", 404)
                }else{
                    
                    let erro1 = error as NSError
                    var errorDes: String = error.localizedDescription
                    switch erro1.code { // 错误码:http://www.jianshu.com/p/82a2125bda76
                    case -1001:
                        errorDes = "网络请求超时"
                        failureClousure?(errorDes, erro1.code)
                    case -1200:
                        errorDes = "网络连接失败"
                        failureClousure?(errorDes, erro1.code)
                    default:
                        failureClousure?(errorDes,5555555)
                    }
                   
                }
                
            }
            
        }
    }
    
}

//MARK: - custom methods
extension RNNetworkManager {
    
    // 清理 cookies 和 当前用户信息
    static func clearCookies() {
        
        let storage = HTTPCookieStorage.shared
        
        guard let cookies = storage.cookies else {
            return
        }
        
        for cookie in cookies {
            storage.deleteCookie(cookie)
        }
        
        // 清除用户信息
      //  UserDefaults.standard.removeObject(forKey: UserDefaultsUserTokenKey)
        // ... 其他保存的信息
        UserDefaults.standard.synchronize()
        URLCache.shared.removeAllCachedResponses()
        
    }
    
}
