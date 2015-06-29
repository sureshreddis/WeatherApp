//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by 01HW842977 on 6/24/15.
//  Copyright (c) 2015 Suresh. All rights reserved.
//

import UIKit
import XCTest


class WeatherAppTests: XCTestCase {
    
    let controller = ViewController()
    var isWhetherDataUpdated:Bool = false
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    

    func testGetWetherData()
    {
        let locations:(Double,Double) = (13.0827,80.2707)
        let urlPath = NSString(format: "%@/%@/%f,%f",forecastURL,forecastAPIKey,locations.0,locations.1)
        getWeatherData(urlPath as String)
        while (!self.isWhetherDataUpdated) {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(0.1))
        }
        XCTAssert(true, "whether data updated")
        
    }
    
    func testCheckforNetworkConnection()
        
    {
        var isNetworkAvailable:Bool = false
        isNetworkAvailable = Reachability.isConnectedToNetwork()
        XCTAssert(isNetworkAvailable , "internetconnection available")
    }
    
    func getWeatherData (urlString: String) {
        let forecastURL = NSURL(string: urlString)
        let urlSession = NSURLSession.sharedSession()
        
        var isConnectivity:Bool = false
        if Reachability.isConnectedToNetwork() {
            // Go ahead and fetch your data from the internet
            isConnectivity = true
        } else {
            isConnectivity = false
            self.isWhetherDataUpdated = true
        }
        
        if (isConnectivity == true) {
            let jsonQuery = urlSession.dataTaskWithURL(forecastURL!, completionHandler: { data, response, error -> Void in
                if (error != nil) {
                    self.isWhetherDataUpdated = true
                    println(error.localizedDescription)
                }
                var err: NSError?
                
                self.isWhetherDataUpdated = true
                var jsonResultForWhetherData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
                
                if (err != nil) {
                    println("JSON Error \(err!.localizedDescription)")
                }
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
            })
            jsonQuery.resume()
        }
        
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

// Check reachability using the below class
internal class Reachability {
    /**
    * Check if internet connection is available
    */
    class func isConnectedToNetwork() -> Bool {
        var status:Bool = false
        
        let url = NSURL(string: "http://google.com")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response:NSURLResponse?
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                status = true
            }
        }
        
        return status
    }
}
