//
//  BaseAPI.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/27.
//  Copyright © 2017年 roni. All rights reserved.
//


/// ## 关于网络的自定义常量字段

import Foundation


//MARK: - base
let BASEURL = "http://www.winployee.com" // 使用

// MARK: Key
let UserToken = "USERTOKEN"
let UserName = "USERNAME"
let Password = "PASSWORD"


//MARK: - error code
let successCode = 0 


// 接口 path

//MARK: - 用户相关
let AppLogin = "http://www.winployee.com/cw-ms/user/login.json" // 登陆
//let ShowInfo = "https://cpnd6.winployee.com/api/att/coGetInfo.json" // 签到界面
var signUrl = "https://cpnd-hz.winployee.com"
var ShowInfo = "\(signUrl)/api/att/coGetInfo.json" // 签到界面
var SignIn = "\(signUrl)/api/att/clockout.json" // 签到
//var SignOut = "\(signUrl)/api/att/clockout.json" // 签退
var SignOut = "\(signUrl)/api/att/clock.json" // 签退
