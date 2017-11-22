//
//  RNHud.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/4.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD
import KRActivityIndicatorView

struct RNHud {
    
    // 使用 KRProgressHUD
    
    init() {
        
    }
    
    /// show KRProgressHUD
    ///
    /// - Parameters:
    ///   - msg: 加载信息
    ///   - style: Style of KRProgressHUD
    ///   - maskType: Type of KRProgressHUD's background view.
    ///   - indicatorStyle: KRActivityIndicatorView's style
    func showHud(_ msg: String?, style: KRProgressHUDStyle = .white, maskType: KRProgressHUDMaskType = .black, indicatorStyle: KRActivityIndicatorViewStyle = .gradationColor(head: UIColor.blue, tail: MAIN_THEME_COLOR) ) {
        
        KRProgressHUD.set(style: style)
        KRProgressHUD.set(maskType: maskType)
        KRProgressHUD.set(activityIndicatorViewStyle: indicatorStyle)
        
        if let m = msg {
            
            KRProgressHUD.showMessage(m)
        }else{
            
            KRProgressHUD.show()
        }
        
        
    }
    
    
    /// show KRProgressHUD
    ///
    /// - Parameters:
    ///   - viewController: 控制器
    ///   - msg: 加载信息
    ///   - style: Style of KRProgressHUD
    ///   - maskType: Type of KRProgressHUD's background view.
    ///   - indicatorStyle: KRActivityIndicatorView's style
    func showOnController(_ viewController: UIViewController, msg: String?, style: KRProgressHUDStyle = .white, maskType: KRProgressHUDMaskType = .black, indicatorStyle: KRActivityIndicatorViewStyle = .gradationColor(head: UIColor.blue, tail: MAIN_THEME_COLOR) ) {
        
        KRProgressHUD.set(style: style)
        KRProgressHUD.set(maskType: maskType)
        KRProgressHUD.set(activityIndicatorViewStyle: indicatorStyle)
        
        if let m = msg {
            
            KRProgressHUD.showOn(viewController).showMessage(m)
        }else{
            
             KRProgressHUD.showOn(viewController).show()
        }
    }

    
    
    /// 设置消失时间
    ///
    /// - Parameter time: 时间
    func setDeadlineTime(deadlineTime time: Double = 2.0) {
        KRProgressHUD.set(deadlineTime: time)
    }
    
    
    /// 设置显示位置
    ///
    /// - Parameter centerPosition: 显示中心坐标
    func setPosition(centerPosition point: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)) {
        
        KRProgressHUD.set(centerPosition: point)
    }
    
    /// hidden KRProgressHUD
    ///
    /// - Parameter callBack: 回调
    func hiddenHub(callBack: (() -> Void)? = nil) {
        
        if let callback = callBack {
            
             KRProgressHUD.dismiss(callback)
        }else{
            
            KRProgressHUD.dismiss()
        }
       
    }
    
    
}
