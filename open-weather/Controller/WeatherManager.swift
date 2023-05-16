//
//  File.swift
//  open-weather
//
//  Created by Manoj Kumar on 11/05/23.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

protocol ForecastManagerDelegate {
    func didUpdateForecast(_ weatherManager: WeatherManager, forecast: [FiveDaysForecast])
    func didForecastFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=fae7190d7e6433ec3a45285ffcf55c86&units=metric&lang=en"
    let forecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=fae7190d7e6433ec3a45285ffcf55c86&units=metric&lang=en"
    
    var delegate: WeatherManagerDelegate?
    var delegateForecast: ForecastManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func fetchForecast(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(forecastURL)&lat=\(latitude)&lon=\(longitude)"
        performForecastRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func performForecastRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegateForecast?.didForecastFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let forecast = self.parseForecastJSON(safeData) {
                        self.delegateForecast?.didUpdateForecast(self, forecast: forecast)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let name = decodedData.name
            
            let lon = decodedData.coord.lon
            let lat = decodedData.coord.lat
            
            let temp = decodedData.main.temp
            let humi = decodedData.main.humidity
            
            let id = decodedData.weather[0].id
            let main = decodedData.weather[0].main
            let desp = decodedData.weather[0].description

            let wind = decodedData.wind.speed
            
            let weather = WeatherModel(lon: lon, lat: lat, conditionId: id, cityName: name, temperature: temp, humidity: humi, main: main, description: desp, wind: wind)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseForecastJSON(_ weatherData: Data) -> [FiveDaysForecast]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ForecastData.self, from: weatherData)
            var fiveForecastData = [String: FiveDaysForecast]()
            
            decodedData.list.forEach { forecast in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

                if let date = dateFormatter.date(from: forecast.dt_txt) {
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                    let stringDate = dateFormatter.string(from: date)
                    fiveForecastData[stringDate] = forecast
                }
                
            }
            return Array(fiveForecastData.values)
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
