//
//  WeatherManager.swift
//  Clima
//
//  Created by Jesus Lopez on 8/9/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, _ weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    let cityApi = "https://api.openweathermap.org/data/2.5/weather?appid=bb6b9729feb3479ba5e42e7ae3639104&units=imperial"
    let coordApi = "https://api.openweathermap.org/data/2.5/weather?appid=bb6b9729feb3479ba5e42e7ae3639104&units=imperial"
    
    func fetchWeather(cityName: String){
        let city = cityName.replacingOccurrences(of: " ", with: "%20")
        let url = "\(cityApi)&q=\(city)"
        performRequest(urlString: url)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees ){
        let url = "\(coordApi)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: url)
    }
    
    func performRequest(urlString: String){
        if let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            
            let  task = session.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJson(safeData) {
                        self.delegate?.didUpdateWeather(self, weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
            let conditionId = decodedData.weather[0].id
            let city = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: conditionId, cityName: city, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
         
    }
    
    
}
