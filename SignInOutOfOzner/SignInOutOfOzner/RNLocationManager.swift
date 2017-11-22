//
//  RNLocationManager.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/12.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


// 定位类

class RNLocationManager: NSObject{
    
//    static var shared = RNLocationManager() // 单例
//    private override init() {
//        
//        super.init()
//        
//        self.requstAuthrization()
//    }
    
    override init() {
        
        super.init()
        
        self.requstAuthrization()
    }
    
    // 回调项
    var coordinateBlock: ((_ currentLocation: CLLocationCoordinate2D) -> Void)? // 坐标回调
    var addressInfoBlock: ((_ province: String, _ city: String, _ area: String) -> Void)? // 返回省市区.. 进行地址编码时都会调用
    var errorBlock: ((String) -> Void)? // 错误回调 ... 根据 authorizationStatus 回调
    var geocoderError: ((String) -> Void)? // 错误回调 ...编码失败
    
    // 设置项
    public var accuracy: CLLocationAccuracy = kCLLocationAccuracyBest // 定位精确度, 默认最高
    public var distanceFilter = 1000.0 // 显示区域 - 默认1000
    public var isAuthrization = CLLocationManager.locationServicesEnabled() as Bool { // 是否有定位权限 -- 使用时可根据此参数显示提示
        
        didSet {
            
            if !oldValue {
                
                self.startLocation()
            }
        }
    }
    
    lazy var currentLocation: CLLocation = {
        let locaction = CLLocation()
        return locaction
    }()
    
    lazy var locationManager: CLLocationManager = {
       let manager = CLLocationManager()
        manager.desiredAccuracy = self.accuracy
        manager.distanceFilter = self.distanceFilter
        manager.delegate = self as CLLocationManagerDelegate
        return manager
    }()
    
    lazy var geocoder: CLGeocoder = {
        let geocoder = CLGeocoder()
        return geocoder
    }()
    
}

//MARK: - custom methods
extension RNLocationManager {

    public func requstAuthrization() { // 请求权限
        
        if locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.locationManager.requestAlwaysAuthorization()
            }
            
        }
    }
    
    public func startLocation(){ // 开始定位
        
       let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .denied:
            if errorBlock != nil {
                errorBlock!("手机未对本应用进行位置授权")
            }
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            requstAuthrization()
            break
        case .restricted:
            if errorBlock != nil {
                errorBlock!("手机未对本应用进行位置授权 -- restricted")
            }
            break
        }
    }
    
    
   /// 反编码
   ///
   /// - Parameters:
   ///   - latitude: 纬度
   ///   - longitude: 经度
   public func getAddress(latitude: Double, longitude: Double) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            guard error == nil, let place = placemarks?.last else{
                
                if self.geocoderError != nil {
                    self.geocoderError!("反编码失败")
                }
                return
            }
            
//            let placemark:CLPlacemark = (pms?.last)!
//            let location = placemark.location;//位置
//            let region = placemark.region;//区域
//            let addressDic = placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
//            let name=placemark.name;//地名
//            let thoroughfare=placemark.thoroughfare;//街道
//            let subThoroughfare=placemark.subThoroughfare; //街道相关信息，例如门牌等
//            let locality=placemark.locality; // 城市
//            let subLocality=placemark.subLocality; // 城市相关信息，例如标志性建筑
//            let administrativeArea=placemark.administrativeArea; // 州
//            let subAdministrativeArea=placemark.subAdministrativeArea; //其他行政区域信息
//            let postalCode=placemark.postalCode; //邮编
//            let ISOcountryCode=placemark.ISOcountryCode; //国家编码
//            let country=placemark.country; //国家
//            let inlandWater=placemark.inlandWater; //水源、湖泊
//            let ocean=placemark.ocean; // 海洋
//            let areasOfInterest=placemark.areasOfInterest; //关联的或利益相关的地标
            
          
            
            if self.addressInfoBlock != nil {
                
                self.addressInfoBlock?(place.administrativeArea ?? "", place.locality ?? "", place.subLocality ?? "")
            }
            
            self.locationManager.stopUpdatingLocation()
           
        }
    }
    
    /// 编码
    ///
    /// - Parameters:
    ///   - address: 地址
    ///   - coordinateBlock: 回调坐标
    public func getCoordinate(address: String, coordinateBlock: ((CLLocationCoordinate2D) -> Void)?) {
        let ge =  CLGeocoder()
        ge.geocodeAddressString(address) { (placemarks, error) in
            guard error == nil, let place = placemarks?.last else{
                
                if self.geocoderError != nil {
                    self.geocoderError!("编码失败")
                }
                return
            }
            
            if let coordinate = place.location?.coordinate {
                 coordinateBlock?(coordinate)
            }

        }
    }
    
}



//MARK: - CLLocationManagerDelegate
extension RNLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation() // 停止定位
        
        let location = locations.last
        guard let loca = location else {
            if errorBlock != nil {
                errorBlock!("未获取到定位信息")
            }
            
            return
        }
        
        self.currentLocation = loca
        let currentCoordinate = (loca as CLLocation).coordinate
        
        if coordinateBlock != nil {
            
            coordinateBlock?(currentCoordinate)
        }
        // 反编码
        getAddress(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        
        locationManager.stopUpdatingLocation() // 关闭 => 避免Failure to deallocate CLLocationManager on the same runloop as its creation may result in a crash

    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .denied:
            if errorBlock != nil {
                errorBlock!("手机未对本应用进行位置授权")
            }
        case .notDetermined:
            requstAuthrization()
            break
            
        case .authorizedAlways,.authorizedWhenInUse:
             locationManager.startUpdatingLocation()
        case .restricted:
            if errorBlock != nil {
                errorBlock!("手机未对本应用进行位置授权 -- restricted")
            }
            break
            
        }

    }
}
