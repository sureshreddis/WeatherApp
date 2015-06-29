//
//  DataServiceParser.swift
//  WeatherApp
//
//  Created by SureshReddy on 6/24/15.
//  Copyright (c) 2015 Suresh. All rights reserved.
//

import Foundation

class DataServiceParser : NSObject {

    var weatherGlobalModelObject:WeatherBaseModel!
    var weatherReportArray:Array<WeatherReportModel>? = [WeatherReportModel]()
    var arrayOfItems:Array<String>? = [String]()
    // MARK:- Create Singleton Which is used across app
    class var sharedInstance : DataServiceParser {
        struct Singleton {
            static let instance = DataServiceParser()
        }
        
        return Singleton.instance
    }

    // MARK: -  This Function is used to parse JSON Response
    func parseValues(jsonData:NSDictionary)
    {
        weatherGlobalModelObject = WeatherBaseModel()
        let jsonTimeZone:String! = jsonData["timezone"] as! String
        var currLatitude:NSNumber = jsonData["latitude"] as! NSNumber
        var currLongitude:NSNumber = jsonData["longitude"] as! NSNumber
        
        if let jsonTimeZone = jsonTimeZone {
            weatherGlobalModelObject.timeZone = jsonTimeZone
        } else {
            weatherGlobalModelObject.timeZone = "No TZ in Response"
        }
        
        weatherGlobalModelObject.longitude = currLongitude.stringValue
        weatherGlobalModelObject.latitude = currLatitude.stringValue
        
        if let addCurrentResult = jsonData["currently"] as? NSDictionary {
        self.addValues(addCurrentResult)
            arrayOfItems?.append("Currently")
        }
        
        if let addMinutelyResult = jsonData["minutely"] as? NSDictionary {
        self.addValues(addMinutelyResult)
            arrayOfItems?.append("Minutely")
        }
        
        if let addHourlyResult = jsonData["hourly"] as? NSDictionary {
        self.addValues(addHourlyResult)
            arrayOfItems?.append("Hourly")
        }
        
        if let addDailyResult = jsonData["daily"] as? NSDictionary {
        self.addValues(addDailyResult)
            arrayOfItems?.append("Daily")
        }
        
    }
    
    // MARK: -  This function is used to add Values
    func addValues (jsonDictData:NSDictionary) {
    
        var weatherReportModelObject = WeatherReportModel()
        weatherReportModelObject.summary = jsonDictData["summary"] as? String
        weatherReportModelObject.icon  = jsonDictData["icon"] as? String
        weatherReportModelObject.temperature = jsonDictData["temperature"] as? String
        weatherReportArray?.append(weatherReportModelObject)
    }
    

}
