//
//  NetworkTester.swift
//  NetworkGateway
//
//  Created by Anthony Holan on 3/30/16.
//  Copyright © 2016 researchnow. All rights reserved.
//

import UIKit
import CoreLocation

//--------------------------------------------------------------------------------------------
class NetworkTester: UIViewController, HttpProtocolDelegate{

    weak var httpDelegate : HttpProtocolDelegate?
    
    //--------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("network service app starting")
        self.httpDelegate = self
        let task = NetworkTask(timestamp: NSDate(), retries: 0, url: "url", priority: .LOW, body: nil, params: nil, type: .GET, statusCode: 0, instantaneous: true)
        NetworkGateway.getSharedInstance().createHttpCall(task)
        NetworkGateway.getSharedInstance().configureGateway(3, timeIntervalInMinutes: 0.2)
        NetworkGateway.getSharedInstance().delegate = self
    }
    
    //--------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------------------------------------------------------------
    func httpCallback<AnyObject>(url:String, response:AnyObject) {
        if(url == "url"){
            let stuff = response as! JSON
                if(stuff.count > 0){
                for i in 0..<stuff.count{
                    let url = stuff[i]
                    let name = url["name"].string!
                    let fullUrl = url["fullUrl"].string!
                    NetworkGateway.urlIndex.setValue(fullUrl, forKey: name)
                }
                NetworkGateway.getSharedInstance().setupTasks()
            }
        }else if(url == "logging"){
            print("data was logged")
        }else if(url == "device"){
            print("receiving device data")
        }
    }
}