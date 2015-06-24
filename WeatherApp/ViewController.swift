//
//  ViewController.swift
//  WeatherApp
//
//  Created by SureshReddy on 6/24/15.
//  Copyright (c) 2015 Suresh. All rights reserved.
//

import UIKit
import CoreLocation

// Declare Constants - URL,API Key etc..
var forecastURL:String = "https://api.forecast.io/forecast"
var forecastAPIKey:String = "b29931b6d706be43f1dcf08ed056dfc9"
var weatherReportArray:Array = [WeatherReportModel]()
var latitudeOfLocation:String?
var longitudeOfLocation:String?
var timeZoneOfLocation:String?
var seenError : Bool = false

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var serviceParserObject = DataServiceParser.sharedInstance

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var labelTimeZone: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var labelSummary: UILabel!
    @IBOutlet weak var labelIcon: UILabel!
    @IBOutlet weak var labelLatitude: UILabel!
    @IBOutlet weak var labelLongitude: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.startAnimating()
        self.view.userInteractionEnabled = false
        
        let locations:(Double,Double) = getCurrentLocation()
        let urlPath = NSString(format: "%@/%@/%f,%f",forecastURL,forecastAPIKey,locations.0,locations.1)
        self.getWeatherData(urlPath as String)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- CLLocation Manager Delegates
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if (error != nil) {
            if (seenError == false) {
                seenError = true
                displayAlert("Error getting location")
            }
        }
    }
    
    
    // MARK:- Segmented Control Index Change
    @IBAction func segControlTapped(sender: AnyObject) {
        var segController:UISegmentedControl = sender as! UISegmentedControl
        switch self.segControl.selectedSegmentIndex {
        case 0:  if let reportModel = self.serviceParserObject.weatherReportArray?[0] {
            self.displayData(reportModel)
            }
        case 1:  if let reportModel = self.serviceParserObject.weatherReportArray?[1] {
            self.displayData(reportModel)
            }
        case 2:  if let reportModel = self.serviceParserObject.weatherReportArray?[2] {
            self.displayData(reportModel)
            }
        default:  if let reportModel = self.serviceParserObject.weatherReportArray?[3] {
            self.displayData(reportModel)
            }
        }
    }
    
    // MARK: -  This Function return Latitude and Longitude of current User Location

    func getCurrentLocation()-> (Double, Double) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let location = self.locationManager.location
        
        //To Check in Simulator ,Click Debug menu then Location and select Apple from the sub menu list.
        //Still nothing happens with the app and no messages are written to the console.
        if let loc = location {
        var  latitude:Double = location.coordinate.latitude
        var longitude: Double = location.coordinate.longitude
        return (latitude,longitude)
        }
        else {
           self.displayAlert("Not able to fetch Location,Please check Location Services in Settings")
            return (0.00,0.00)
        }
        return (0.00,0.00)
    }
    
    // MARK: -  This is internal Class used to check Network Connectivity
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
    
    // MARK: -  This Function is used to get Weather Data by passing URL as a parameter
    func getWeatherData (urlString: String) {
        let forecastURL = NSURL(string: urlString)
        let urlSession = NSURLSession.sharedSession()
        var isConnectivity:Bool = false
        
        if Reachability.isConnectedToNetwork() {
            // Go ahead and fetch your data from the internet
            isConnectivity = true
        } else {
            isConnectivity = false
            displayAlert("Please ensure you are connected to the Internet")
        }
        
        if (isConnectivity == true) {
        // Initiate json Request
        let jsonQuery = urlSession.dataTaskWithURL(forecastURL!, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if (err != nil) {
                self.activityView.stopAnimating()
                self.activityView.removeFromSuperview()
                self.view.userInteractionEnabled = true
            }
            // Parse Json Response
            self.serviceParserObject.parseValues(jsonResult)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.activityView.stopAnimating()
                self.activityView.removeFromSuperview()
                self.view.userInteractionEnabled = true
                
                self.labelLatitude.text = self.serviceParserObject.weatherGlobalModelObject.latitude
                self.labelLongitude.text = self.serviceParserObject.weatherGlobalModelObject.longitude
                self.labelTimeZone.text = self.serviceParserObject.weatherGlobalModelObject.timeZone
                
                if let reportModel = self.serviceParserObject.weatherReportArray?[0] {
                    self.displayData(reportModel)
                }
            })
        })
        jsonQuery.resume()
        
        }
        else {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            self.view.userInteractionEnabled = false
        }
    }
    
     // MARK: -  Custom Alert Function by passing message as parameter
    func displayAlert (message:String) {
        // For
        var alert = UIAlertView(title: "Alert!", message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        
    }
    
    
    // MARK: -  This function is used to display data
    func displayData(weatherRepModel:WeatherReportModel) {
        
        self.labelSummary.text = weatherRepModel.summary
        self.labelIcon.text = weatherRepModel.icon
        
        if let dayType = weatherRepModel.icon {
            switch dayType {
            case "partly-cloudy-day" :
                self.iconImage.image = UIImage(named:"partly_cloudy_Image")
            case "partly-cloudy-night" :
                self.iconImage.image = UIImage(named:"partly_cloudy_night_Image")
            case "rain":
                self.iconImage.image = UIImage(named:"rainy_Image")
            case "clear-night":
                self.iconImage.image = UIImage(named:"clear_night_Image")
            case "sunny":
                self.iconImage.image = UIImage(named:"sunny_Image")
            case "clear-day":
                self.iconImage.image = UIImage(named:"clear_day_Image")
            default:
                self.iconImage.image = UIImage(named:"default_Image")
            }
        }
    }
    
}

