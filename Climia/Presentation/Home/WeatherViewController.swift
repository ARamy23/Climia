//
//  ViewController.swift
//  Climia
//
//  Created by Ahmed Ramy on 2/6/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

/*
 1. Has Direct access to App Secrets and URLs
 2. Calls Location Manager directly and does logic based on the location
 3. Does networking and parses the network responses
 4. Navigates to other views
 5. too many side effects and violation of single responsibility principle
 */
class WeatherViewController: UIViewController, CLLocationManagerDelegate , ChangeCityDelegate
{

    //MARK: Constants
    
    // Refactoring mark: Should move to xcconfig file
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "ce30986ae5a18800b94e827061fb63f5"
    
    //MARK: Declare instance variables
    
    // Refactoring mark: location should be moved to an external protocol and be called from behind that protocol
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //MARK : linked IBOutlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // Refactoring mark: ViewDidLoad logic should be moved to presentation layer
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK : locationManager settings
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //best for weather apps
        locationManager.requestWhenInUseAuthorization() //best for privacy assurance
        locationManager.startUpdatingLocation() //Asynchronous Method (Keeps updating in the background)
        
    }
    
    // Refactoring mark: Networking be externalized
    //MARK: - Networking
    /***********************************************/
    func getWeatherData(url: String , parameters: [String: String])
    {
        Alamofire.request(url ,method: .get , parameters: parameters).responseJSON { (response) in
            if (response.result.isSuccess)
            {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else
            {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    // Refactoring mark: Parsing should be the responsibility of the network layer
    //MARK: - JSON Parsing
    /***********************************************/
    func updateWeatherData(json: JSON)
    {
        if let tempResult = json["main"]["temp"].double
        {
        
            weatherDataModel.temperature = Int(tempResult - 273.15) //temp is recieved in Fahrenheit so we subtract 273.15 from it to return it to Celsius
            weatherDataModel.city = json["name"].stringValue //similar to .toString function in java
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWeatherData()
        }
        else
        {
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    
    //MARK: - UI Updates
    /***********************************************/
    func updateUIWeatherData()
    {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    //MARK: - Location Manager Delegate Methods
    /***********************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1] 
        if location.horizontalAccuracy > 0
        {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            //converting latitude and longitude to constants for re-use
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL , parameters: params)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable!"
    }
    
    //MARK: - Change City Delegate Methods
    /***********************************************/
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city , "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        
    }
    
    // Refactoring mark: Externalize to a router
    //MARK: - Navigation
    /******************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToChangeCityViewController"
        {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    
    
}

