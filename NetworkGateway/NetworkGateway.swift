//
//  ViewController.swift
//  NetworkGateway
//
//  Created by Anthony Holan on 3/25/16.
//  Copyright © 2016 researchnow. All rights reserved.
//

import UIKit
import Alamofire

// version, user agent, capped, retry, keep-alive

protocol HttpProtocolDelegate: class{
    func httpCallback<T>(url:String, response:T)
}

enum Priority: Int{
    case LOW = 1, MEDIUM, HIGH
}

struct NetworkTask{
    var timestamp : NSDate
    var retries : Int
    var url : String
    var priority : Priority
    var body : JSON?
    var params : [String:AnyObject]?
    var type : Alamofire.Method
    var statusCode : Int
    var instantaneous : Bool
}

struct UrlObject{
    var name:String
    var fullUrl:String
}


class NetworkGateway : NSObject{
 
    static var api_key = "a122f2d4-517c-4804-b343-6c480dca7b5d"
    static var TitanURLS = "https://titan-dev.researchnow.com/api/url"
    static var BaseURL = "https://titan-dev.researchnow.com/api/"
    var callList = [NetworkTask]()
    static var urlIndex = NSMutableDictionary()
    private static let sharedInstance = NetworkGateway()
    private var processAmount = 3                              // default value is three
    private var processTimer = NSTimer()
    weak var delegate:HttpProtocolDelegate?
    
    //----------------------------------------------------------------------------
    class func getSharedInstance()->NetworkGateway{
        return sharedInstance
    }
    
    //----------------------------------------------------------------------------
    func configureGateway(amount:Int, timeIntervalInMinutes:Double){
        let interval = timeIntervalInMinutes * 60
        NetworkGateway.sharedInstance.processAmount = amount
        NetworkGateway.sharedInstance.processTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "processTasks", userInfo: nil, repeats: true)
        print("Network gateway configured")
    }
    
    //----------------------------------------------------------------------------
    func createHttpCall(task:NetworkTask){
        // If instantaneous, create appropriate call and return the data
        if(task.instantaneous){
            createRequest(task)
        }else{
            self.callList.append(task)
        }
    }
    
    //----------------------------------------------------------------------------
    func processTasks(){
        for index in 0..<self.processAmount{
            if(self.callList.count > index){
                let task = self.callList.removeAtIndex(index)
                NetworkGateway.sharedInstance.createRequest(task)
            }
        }
    }
 
    //--------------------------------------------------------------------------------------------
    func createRequest(var task:NetworkTask){
        do{
            let urlString = (task.url == "url") ? "https://titan-dev.researchnow.com/api/url" : NetworkGateway.urlIndex.valueForKey(task.url) as! String
            let URL = NSURL(string: urlString)
            let mutableURLRequest = NSMutableURLRequest(URL: URL!)
            mutableURLRequest.HTTPMethod = self.getHttpMethod(task.type)
            mutableURLRequest.HTTPBody = try task.body?.rawData()
            mutableURLRequest.timeoutInterval = 5.0
            mutableURLRequest.addValue(NetworkGateway.api_key, forHTTPHeaderField: "token")
            mutableURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            Alamofire.request(mutableURLRequest)
                .responseJSON{
                response in
                    let status:Int = (response.response?.statusCode)!
                    switch(status){
                    case 200:
                        do{
                            let json = try NSJSONSerialization.JSONObjectWithData((response.data)!, options: NSJSONReadingOptions.AllowFragments)
                            self.processData(task.url, data: JSON(json))
                            self.delegate?.httpCallback(task.url, response: JSON(json))
                        }catch _{
                            
                        }
                        break
                    case 204..<205:
                        break
                    case 300..<399:
                        //lets get the urls again
                        break
                    case 401:
                        //let's log em out
                        break
                    case 404:
                        // refetch urls
                        break
                    case 500:
                        //let's perform retries if any
                        task.retries-=1
                        // I can add a timed dispatch here if we'd like to retry but not immediately
                        self.createRequest(task)
                        print("Request failed")
                        break
                    default:
                        break
                    }
            }
        }catch _{
            print("There was an error")
        }
    }

    //--------------------------------------------------------------------------------------------
    func setupTasks(){
        let json:JSON = [["level" : "info",
            "category" : "anthonySucksAtCoding",
            "message" : "uploading geo data",
            "researchNowDeviceId" : "anthonySucks",
            "localTime" : "2015-08-24T14:00:04-05:00",
            "brandId": 1,
            "platformType" : 1,
            "latitude" : 33.0898,
            "longitude" : -96.3452],["level" : "info",
                "category" : "anthonySucksAtCoding",
                "message" : "uploading geo data",
                "researchNowDeviceId" : "anthonySucks",
                "localTime" : "2015-08-24T14:00:04-05:00",
                "brandId": 1,
                "platformType" : 1,
                "latitude" : 33.0898,
                "longitude" : -96.3452]]
        for _ in 0..<10{
            let task = NetworkTask(timestamp: NSDate(), retries: 2, url: "logging", priority: .LOW, body: json, params: nil, type: .POST, statusCode: 0, instantaneous: false)
            self.createHttpCall(task)
        }
        for _ in 0..<10{
            let task = NetworkTask(timestamp: NSDate(), retries: 0, url: "device", priority: .LOW, body: nil, params: nil, type: .GET, statusCode: 0, instantaneous: false)
            self.createHttpCall(task)
        }
    }
    
    //--------------------------------------------------------------------------------------------
    func getHttpMethod(type:Alamofire.Method)->String{
        switch(type)
        {
            case .GET:
                return "GET"
            case .POST:
                return "POST"
            case .DELETE:
                return "DELETE"
            case .PUT:
                return "PUT"
            default:
                return "GET"
        }
    }
    
    //--------------------------------------------------------------------------------------------
    func processData(index:String, data:JSON){
        switch(index){
            case "abtesting":
                break
            case "applicationlaunch":
                break
            case "applicationupgrade":
                break
            case "authentication":
                break
            case "balance":
                break
            case "configuration":
                break
            case "contact":
                break
            case "device":
                break
            case "geofencetracking":
                break
            case "geofencing":
                break
            case "geoproject":
                break
            case "legal":
                break
            case "location":
                break
            case "logging":
                break
            case "panelinfo":
                break
            case "password":
                break
            case "projectcriteria":
                break
            case "projecteligibility":
                break
            case "pushtracking":
                break
            case "rateourapp":
                break
            case "registration":
                break
            case "resendactivationemail":
                break
            case "respondent":
                break
            case "url":
                print("The url was called")
                break
            case "usersettings":
                break
            case "validation":
                break
            case "verification":
                break
            default:
                break
        }
    }
}

