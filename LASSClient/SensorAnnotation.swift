//
//  SensorAnnotation.swift
//  LASSClient
//
//  Created by formosa on 1/20/16.
//  Copyright © 2016 formosa. All rights reserved.
//

import UIKit
import MapKit

class SensorAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var deviceid: String
    var dust: Double!
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, deviceid: String, dust: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.deviceid = deviceid
        //self.dust = (dust as NSString).doubleValue
        self.dust = Double(dust)
        
        super.init()
    }
    
    func pinColor() -> UIColor {
        var theColor: UIColor
        if (dust < 0.0) {
            theColor = .black
        } else if (dust < 20.0) {
            theColor = .green
        } else if (dust < 35.0) {
            theColor = .yellow
        } else if (dust < 50.0) {
            theColor = .orange
        } else if (dust < 65.0) {
            theColor = .red
        } else if (dust < 80.0) {
            theColor = .purple
        } else {
            theColor = .magenta
        }
        //print("\(dust!) \(theColor)")
        
        return theColor
    }
}
