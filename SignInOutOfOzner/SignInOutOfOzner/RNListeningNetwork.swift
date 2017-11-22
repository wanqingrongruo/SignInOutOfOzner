//
//  RNListeningNetwork.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/27.
//  Copyright © 2017年 roni. All rights reserved.
//

/// ## 网络监听

import Foundation
import Alamofire


class RNListeningNetwork {
    static let shared =  RNListeningNetwork() // 监听网络的单例
    
    internal let manager = NetworkReachabilityManager(host: "www.baidu.com")
    
    private init() {

        manager?.startListening()
    }
    
}
