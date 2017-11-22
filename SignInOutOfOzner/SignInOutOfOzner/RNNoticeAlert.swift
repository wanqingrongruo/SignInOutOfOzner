//
//  RNNoticeAlert.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/3.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import SwiftMessages


struct RNNoticeAlert {
    
    
//    public enum Layout: String {
//        
//        /**
//         The standard message view that stretches across the full width of the
//         container view.
//         */
//        case MessageView = "MessageView"
//        
//        /**
//         A floating card-style view with rounded corners.
//         */
//        case CardView = "CardView"
//        
//        /**
//         Like `CardView` with one end attached to the super view.
//         */
//        case TabView = "TabView"
//        
//        /**
//         A 20pt tall view that can be used to overlay the status bar.
//         Note that this layout will automatically grow taller if displayed
//         directly under the status bar (see the `ContentInsetting` protocol).
//         */
//        case StatusLine = "StatusLine"
//        
//        /**
//         A standard message view like `MessageView`, but without
//         stack views for iOS 8.
//         */
//        case MessageViewIOS8 = "MessageViewIOS8"
//    }

   
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - body: 提示内容
    ///   - layout: 卡片类型
    ///   - presentationStyle: 展示方式
    ///   - duration: 动画时间
    static func showSuccess(_ title: String, body: String, layout: String = "CardView", presentationStyle: SwiftMessages.PresentationStyle = .top, duration: TimeInterval = 1.25) {
     
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: title, body: body)
        success.button?.setTitle("关闭", for: . normal)
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = presentationStyle
        successConfig.duration = .seconds(seconds: duration)
        successConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        success.buttonTapHandler = { _ in SwiftMessages.hide() }
        
        
        SwiftMessages.show(config: successConfig, view: success)

    }
    
    
    /// 成功显示
    ///
    /// - Parameters:
    ///   - title: <#title description#>
    ///   - body: <#body description#>
    ///   - layout: <#layout description#>
    ///   - presentationStyle: <#presentationStyle description#>
    ///   - buttonTapHandler: 按钮事件
    static func showSuccessWithForever(_ title: String, body: String, layout: String = "CardView", presentationStyle: SwiftMessages.PresentationStyle = .bottom, buttonTapHandler: ((_ button: UIButton) -> Void)?) {
        
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: title, body: body)
        success.button?.setTitle("确定", for: . normal)
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = presentationStyle
        successConfig.duration = .forever
        successConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        success.buttonTapHandler = buttonTapHandler
        
        SwiftMessages.show(config: successConfig, view: success)
        
    }

    
     /// 失败
    static func showError(_ title: String, body: String, layout: String = "CardView", presentationStyle: SwiftMessages.PresentationStyle = .top, duration: TimeInterval = 1.25) {
        
        let error = MessageView.viewFromNib(layout: .cardView)
        error.configureTheme(.error)
        error.configureDropShadow()
        error.configureContent(title: title, body: body)
        error.button?.setTitle("关闭", for: . normal)
        var errorConfig = SwiftMessages.defaultConfig
        errorConfig.presentationStyle = presentationStyle
        errorConfig.duration = .seconds(seconds: duration)
        errorConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        error.buttonTapHandler = { _ in SwiftMessages.hide() }
        
        SwiftMessages.show(config: errorConfig, view: error)
        
    }
    
    /// 警告
    static func showWarning(_ title: String, body: String, layout: String = "CardView", presentationStyle: SwiftMessages.PresentationStyle = .top, duration: TimeInterval = 1.25) {
        
        let warning = MessageView.viewFromNib(layout: .cardView)
        warning.configureTheme(.warning)
        warning.configureDropShadow()
        warning.configureContent(title: title, body: body)
        warning.button?.setTitle("关闭", for: . normal)
        var warningConfig = SwiftMessages.defaultConfig
        warningConfig.presentationStyle = presentationStyle
        warningConfig.duration = .seconds(seconds: duration)
        warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        warning.buttonTapHandler = { _ in SwiftMessages.hide() }
        
        SwiftMessages.show(config: warningConfig, view: warning)
        
    }
    
    /// 需要确认的警告
    static func showWarningWithForever(_ title: String, body: String, layout: String = "CardView", presentationStyle: SwiftMessages.PresentationStyle = .bottom, buttonTapHandler: ((_ button: UIButton) -> Void)?) {
        
        let warning = MessageView.viewFromNib(layout: .cardView)
        warning.configureTheme(.error)
        warning.configureDropShadow()
        warning.configureContent(title: title, body: body)
        warning.button?.setTitle("确定", for: . normal)
        var warningConfig = SwiftMessages.defaultConfig
        warningConfig.presentationStyle = presentationStyle
        warningConfig.duration = . forever
        warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        warning.buttonTapHandler = buttonTapHandler
        
        SwiftMessages.show(config: warningConfig, view: warning)
        
    }

    
    /// info
    static func showInfo(_ title: String, body: String, layout: String = "CardView", presentationStyle: SwiftMessages.PresentationStyle = .top, duration: TimeInterval = 1.25) {
        
        let info = MessageView.viewFromNib(layout: .cardView)
        info.configureTheme(.info)
        info.configureDropShadow()
        info.configureContent(title: title, body: body)
        info.button?.setTitle("关闭", for: . normal)
        var infoConfig = SwiftMessages.defaultConfig
        infoConfig.presentationStyle = presentationStyle
        infoConfig.duration = .seconds(seconds: duration)
        infoConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        info.buttonTapHandler = { _ in SwiftMessages.hide() }
        
        SwiftMessages.show(config: infoConfig, view: info)
        
    }
    
    /// statu
    static func showInStatus(_ title: String, body: String, layout: String = "StatusLine", presentationStyle: SwiftMessages.PresentationStyle = .top, duration: TimeInterval = 1.25) {
        
        let status = MessageView.viewFromNib(layout: .statusLine)
        status.backgroundView.backgroundColor = UIColor.purple
        status.bodyLabel?.textColor = UIColor.white
        status.configureContent(body: body)
        var statusConfig = SwiftMessages.defaultConfig
        statusConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        statusConfig.duration = .seconds(seconds: duration)
        
        status.buttonTapHandler = { _ in SwiftMessages.hide() }
        
        SwiftMessages.show(config: statusConfig, view: status)
    }

    
    /// statu
    static func showInLightStatus(_ title: String, body: String, layout: String = "StatusLine", presentationStyle: SwiftMessages.PresentationStyle = .top, duration: TimeInterval = 1.25) {
        
        let status2 = MessageView.viewFromNib(layout: .statusLine)
        status2.backgroundView.backgroundColor = UIColor.orange
        status2.bodyLabel?.textColor = UIColor.white
        status2.configureContent(body: body)
        var status2Config = SwiftMessages.defaultConfig
        status2Config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        status2Config.preferredStatusBarStyle = .lightContent
        status2Config.duration = .seconds(seconds: duration)
        SwiftMessages.show(config: status2Config, view: status2)
        
    }

   // CenteredView - 转单
    static func showCenterView(title: String? = "提示", body: String, width: CGFloat = 250, backgroundColor: UIColor = UIColor.white, radius: CGFloat = 5,  buttonTitle: String = "确定", callBack: (()->())?) {
        
//        let messageView: MessageView = MessageView.viewFromNib(layout: .CenteredView)
//        messageView.configureBackgroundView(width: width)
//        messageView.configureContent(title: title, body: body, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: buttonTitle) { _ in
//            
//            callBack?()
//            
//            SwiftMessages.hide()
//        }
//        messageView.backgroundView.backgroundColor = backgroundColor
//        messageView.backgroundView.layer.cornerRadius = radius
//        var config = SwiftMessages.defaultConfig
//        config.presentationStyle = .center
//        config.duration = .forever
//        config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
//        config.presentationContext  = .window(windowLevel: UIWindowLevelStatusBar)
//         messageView.buttonTapHandler = { _ in SwiftMessages.hide() }
//        SwiftMessages.show(config: config, view: messageView)

    }
    
    
    // 隐藏
    static func hideMessage() {
        
        SwiftMessages.hide()
    }
    
    static func hideAll() {
        
        SwiftMessages.hideAll()
    }

}
