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
        
        var addCurrentResult = jsonData["currently"] as! NSDictionary
        self.addValues(addCurrentResult)
        
        var addMinutelyResult = jsonData["minutely"] as! NSDictionary
        self.addValues(addMinutelyResult)
        
        var addHourlyResult = jsonData["hourly"] as! NSDictionary
        self.addValues(addHourlyResult)
        
        var addDailyResult = jsonData["daily"] as! NSDictionary
        self.addValues(addDailyResult)
        
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