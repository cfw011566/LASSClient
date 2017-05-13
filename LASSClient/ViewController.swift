//
//  ViewController.swift
//  LASSClient
//
//  Created by formosa on 1/15/16.
//  Copyright © 2016 formosa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CocoaMQTT

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let kStatusTimerSeconds: Double = 60.0
    
    var refreshTimer: Timer?
    
    let kThresholdSpanDelta = 1.0
    let kDefaultSpanDelta = 0.05
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D!
    var mqtt: CocoaMQTT?
    var sensorInfo = [[String : String]]()

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopRefreshTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mqttSetting()
        mqtt!.connect()
        
        if #available(iOS 9.0, *) {
            // mapView.showsTraffic = true
        } else {
            // Fallback on earlier versions
        }
        
        self.addNavItem()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        
        startRefreshTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: MQTT
    
    func mqttSetting() {
        let clientIdPid = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
//        mqtt = CocoaMQTT(clientId: clientIdPid, host: "192.168.2.184", port: 1883)
        mqtt = CocoaMQTT(clientID: clientIdPid, host: "gpssensor.ddns.net", port: 1883)
        if let mqtt = mqtt {
//            mqtt.username = "test"
//            mqtt.password = "public"
//            mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
            mqtt.keepAlive = 90
            mqtt.delegate = self
        }
    }
    
    func mqttToSensorInfo(_ mqttinput: String) {
        var sensorData = [String:String]()
        let inputArray = mqttinput.characters.split(separator: "|")
        for i in inputArray {
            let keyvalue = String(i).characters.split(separator: "=")
            if keyvalue.count >= 2 {
                let key = String(keyvalue[0])
                let value = String(keyvalue[1])
                sensorData[key] = value
            }
        }
        addSensorData(sensorData)
    }
    
    func addSensorData(_ data : [String:String]) {
        let deviceID = "device_id"
//        print(self.sensorInfo.count)
        if (self.sensorInfo.isEmpty) {
            self.sensorInfo.append(data)
//            print("\(data[deviceID]!)<---")
        } else {
            for (i, sensorData) in self.sensorInfo.enumerated() {
                if (data[deviceID] == sensorData[deviceID]) {
//                    print("---> \(data[deviceID]!)")
                    self.sensorInfo[i] = data
                    return
                }
            }
            self.sensorInfo.append(data)
        }
        //print("count = \(self.sensorInfo.count)")
    }
    
    func addNavItem() {
        let refreshButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ViewController.refreshAnnotation(_:)))
    
        let locButton: UIButton = UIButton(type: .custom)
        locButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let locImage = UIImage(named: "location")?.withRenderingMode(.alwaysTemplate)
        locButton.setImage(locImage, for: UIControlState())
        locButton.addTarget(self, action: #selector(ViewController.setUserLocation(_:)), for: .touchUpInside)
        let locButtonItem: UIBarButtonItem = UIBarButtonItem(customView: locButton)
        
        self.navigationItem.setRightBarButtonItems([refreshButtonItem, locButtonItem] , animated: false)
    }
    
    func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(timeInterval: kStatusTimerSeconds, target: self, selector: #selector(updateAnnotation), userInfo: nil, repeats: true)
    }
    
    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
   
    func updateAnnotation() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        for info in self.sensorInfo {
            if (info["device_id"] == nil || info["s_d0"] == nil || info["gps_lon"] == nil || info["gps_lat"] == nil) {
                continue
            }
//            print(info)
            //let mylongitude:Double = (info["gps_lon"]! as NSString ).doubleValue
            //let mylatitude:Double = (info["gps_lat"]! as NSString ).doubleValue
            let mylongitude:Double = Double(info["gps_lon"]!)!
            let mylatitude:Double = Double(info["gps_lat"]!)!
            let myLoc = CLLocationCoordinate2D(latitude: mylatitude, longitude: mylongitude)
            
            let deviceID = info["device_id"]! 
            let dustG3 = info["s_d0"]!
            var dustGrove = ""
            if (info["s_d1"] != nil) {
                dustGrove = info["s_d1"]!
            }
            let myTitle = "\(deviceID)  \(dustG3)/\(dustGrove)"
            
            var temperature = ""
            if (info["s_t0"] != nil) {
                temperature = info["s_t0"]!
            } else if (info["s_t2"] != nil) {
                temperature = info["s_t2"]!
            } else {
                continue
            }
            var humidity = ""
            if (info["s_h0"] != nil) {
                humidity = info["s_h0"]!
            } else if (info["s_h2"] != nil) {
                humidity = info["s_h2"]!
            } else {
                continue
            }
            let date = info["date"]!
            var time = info["time"]!
            if ((time.characters.count) <= 5) {
                time += ":00"
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let mydatetime = dateFormatter.date(from: "\(date) \(time)")
            dateFormatter.timeZone = TimeZone.current
            let mySubtitle = "\(temperature)℃ \(humidity)% [\(dateFormatter.string(from: mydatetime!))]"
            
            let annotation = SensorAnnotation(coordinate: myLoc, title: myTitle, subtitle: mySubtitle, deviceid: deviceID, dust: dustG3)
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: Navigation Item function
    
    func refreshAnnotation(_ sender: UIButton) {
        updateAnnotation()
    }
    
    func setUserLocation(_ sender: UIButton) {
        self.locationManager.startUpdatingLocation()
        if currentLocation != nil {
            self.mapView.setCenter(currentLocation, animated: true)
            if self.mapView.region.span.latitudeDelta > kThresholdSpanDelta {
                let coordinateRegion = MKCoordinateRegionMake(currentLocation, MKCoordinateSpan(latitudeDelta: kDefaultSpanDelta, longitudeDelta: kDefaultSpanDelta))
                self.mapView.setRegion(coordinateRegion, animated: true)
            }
        }
    }
}

// MARK: CocoaMQTTDelegate

extension ViewController: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        //print("didConnectAck \(ack.rawValue)")
        if ack == .accept {
//            mqtt.subscribe("LASS/Test/PM25", qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe("LASS/#", qos: CocoaMQTTQOS.qos1)
            mqtt.ping()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(String(describing: message.string))")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
//        print("didReceivedMessage: \(message.string!) with id \(id)")
        if ((message.string?.hasPrefix("|ver_format=3")) == true) {
            mqttToSensorInfo(message.string!)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MQTTMessageNotification"), object: self, userInfo: ["message": message.string!, "topic": message.topic])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        _console("mqttDidDisconnect")
    }
    
    func _console(_ info: String) {
        print("Delegate: \(info)")
    }
    
}

// MARK: CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.currentLocation = locationManager.location?.coordinate
        if (currentLocation != nil) {
            self.mapView.setCenter(currentLocation, animated: true)
            if self.mapView.region.span.latitudeDelta > kThresholdSpanDelta {
                let coordinateRegion = MKCoordinateRegionMake(currentLocation, MKCoordinateSpan(latitudeDelta: kDefaultSpanDelta, longitudeDelta: kDefaultSpanDelta))
                self.mapView.setRegion(coordinateRegion, animated: true)
            }
        }
    }
    
}

// MARK: MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? SensorAnnotation {
            let identifier = "sensorinfo"
            var view: MKPinAnnotationView
            /*
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                view.pinTintColor = annotation.pinColor()
            }
            */
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            view.pinTintColor = annotation.pinColor()
            return view
        }
        return nil
    }
}

