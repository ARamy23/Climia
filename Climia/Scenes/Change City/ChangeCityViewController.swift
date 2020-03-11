//
//  ChangeCityViewController.swift
//  Climia
//
//  Created by Ahmed Ramy on 2/7/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate
{
    func userEnteredANewCityName (city : String)
}

class ChangeCityViewController: UIViewController {
    
    //MARK: Variables
    var delegate : ChangeCityDelegate?
    
    //MARK: Outlet
    @IBOutlet weak var changeCityTextField: UITextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func getWeatherPressed(_ sender: UIButton)
    {
        //1- Get the city name the user entered
        let cityName = changeCityTextField.text!
        //2- If we have a delegate set, call the method userEnteredANewCityName()
        delegate?.userEnteredANewCityName(city: cityName)
        //3- dismiss the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func dismissChangeCityView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
