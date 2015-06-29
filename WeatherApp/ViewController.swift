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
var latitudeOfLocation:CLLocationDegrees?
var longitudeOfLocation:CLLocationDegrees?
var seenError : Bool = false
var isGetLocation:Int = 0

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var activityView:UIActivityIndicatorView!
    var serviceParserObject = DataServiceParser.sharedInstance

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var labelTimeZone: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var labelSummary: UILabel!
    @IBOutlet weak var labelIcon: UILabel!
    @IBOutlet weak var labelLatitude: UILabel!
    @IBOutlet weak var labelLongitude: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.userInteractionEnabled = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        if Reachability.isConnectedToNetwork() {
            // Go ahead and fetch your data from the internet
            self.createActivityView()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            displayAlert("Network Connectivity Failure.\nPlease check you are connected to the Internet/Network")
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Add Activity View to the Centre of the View
    func createActivityView() {
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
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
            
            if placemarks.count > 0
            {
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocation(pm)
            }
        })
    }
    
    // MARK:- Get Latitude and Longitude from CLPlacemark
    func displayLocation(placeMark: CLPlacemark) {
        self.locationManager.stopUpdatingLocation()
        longitudeOfLocation = placeMark.location.coordinate.longitude
        latitudeOfLocation = placeMark.location.coordinate.latitude
        
        // Avoid Hitting Weather Request Multiple Times
        if isGetLocation == 0 {
            isGetLocation++
            self.hitWeatherRequest()
        }
        
    }
    
    // MARK:- Hit Request with the parameters
    func hitWeatherRequest() {
        
        let urlPath = NSString(format: "%@/%@/%f,%f",forecastURL,forecastAPIKey,latitudeOfLocation!,longitudeOfLocation!)
        self.getWeatherData(urlPath as String)

    }
    
    // CLLocationManager Failure Delegate
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
        

        //if (checkForString == true) {
            if let reportModel = self.serviceParserObject.weatherReportArray?[sender.selectedSegmentIndex] {
                self.displayData(reportModel)
            }
        //}
        else {
            self.displayAlert("Data is not available for \(title)")
        }
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
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
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
                self.modifySegControl()
                
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
    
    func modifySegControl() {
        
        var titleIndex:Int = 0
        var arrayOfStrings:[String] = self.serviceParserObject.arrayOfItems!
        var checkForString:Bool = false
        for titleString in arrayOfStrings {
            var title = self.segControl.titleForSegmentAtIndex(titleIndex)
            if titleString == title {
                titleIndex++
                continue
            } else {
                self.segControl.removeSegmentAtIndex(titleIndex, animated: false)
                titleIndex++
            }
            
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
                self.iconImage.image = UIImage(named:"dafault_Image")
            }
        }
    }
    
}

