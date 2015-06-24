//
//  WeatherReportModel.swift
//  WeatherApp
//
//  Created by SureshReddy on 6/24/15.
//  Copyright (c) 2015 Suresh. All rights reserved.
//

import Foundation

// MARK:- Store Lat,Long and TimeZone which is constant across the app
struct WeatherBaseModel {
    var latitude:String?
    var longitude:String?
    var timeZone:String?
}
// MARK:- Store temp,summary and icon for all the weather conditions
class WeatherReportModel {
    var temperature : String?
    var summary:String?
    var icon:String?
}
