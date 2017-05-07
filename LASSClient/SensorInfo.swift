//
//  SensorInfo.swift
//  LASSClient
//
//  Created by formosa on 1/19/16.
//  Copyright © 2016 formosa. All rights reserved.
//

import Foundation

struct SensorInfo {
    let version: Int        // ver_format=3
    let option: Int         // fmt_opt=0
    let appName: String     // app=PM25
    let appVersion: String  // ver_app=0.7.13
    let deviceID: String    // device_id=FT1_002
    let tick: String        // tick=2059873255
    let date: String        // date=2016-01-15
    let time: String        // time=13:47:53
    let deviceName: String  // device=LinkItOne
    let sequenceNumber: Double  // s_0=34466.00
    let batteryLevel: Double    // s_1=100.00
    let batteryMode: Double     // s_2=1.00 [battery mode(0) or charging(1)]
    let motionSpeed: Double     // s_3=0.00
    let dustG3: Double          // s_d0=48.00 [G3 dust sensor]
    let dustGrove: Double       // s_d1=61.00 [Grove dust sensor]
    let temperature: Double     // s_t0=22.30
    let humidity: Double        // s_h0=68.20
    let longitude: Double   // gps_lon=121.275432
    let latitude: Double    // gps_lat=25.030695
    let altitude: Int       // gps_alt=2 [altitude]
    let gpsFix: Int         // gps_fix=1 [0:invalid 1:GPS fix 2:DGPS fix]
    let gpsNum: Int         // gps_num=17
    
    init(version: String, option: String, appName: String, appVersion: String, deviceID: String, tick:String, date: String, time: String, deviceName: String, sequenceNumber: String, batteryLevel: String, batteryMode: String, motionSpeed: String, dustG3: String, dustGrove: String, temperature: String, humidity: String, longitude: String, latitude: String, altitude: String, gpsFix: String, gpsNum: String) {
        self.version = (version as NSString).integerValue
        self.option = (option as NSString).integerValue
        self.appName = appName
        self.appVersion = appVersion
        self.deviceID = deviceID
        self.tick = tick
        self.date = date
        self.time = time
        self.deviceName = deviceName
        self.sequenceNumber = (sequenceNumber as NSString).doubleValue
        self.batteryLevel = (batteryLevel as NSString).doubleValue
        self.batteryMode = (batteryMode as NSString).doubleValue
        self.motionSpeed = (motionSpeed as NSString).doubleValue
        self.dustG3 = (dustG3 as NSString).doubleValue
        self.dustGrove = (dustGrove as NSString).doubleValue
        self.temperature = (temperature as NSString).doubleValue
        self.humidity = (humidity as NSString).doubleValue
        self.longitude = (longitude as NSString).doubleValue
        self.latitude = (latitude as NSString).doubleValue
        self.altitude = (altitude as NSString).integerValue
        self.gpsFix = (gpsFix as NSString).integerValue
        self.gpsNum = (gpsNum as NSString).integerValue
    }
    
}