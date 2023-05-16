//
//  WeatherModel.swift
//  open-weather
//
//  Created by Manoj Kumar on 11/05/23.
//

import Foundation

struct WeatherModel {
    let lon: Double
    let lat: Double
    let conditionId: Int
    let cityName: String
    let temperature: Double
    let humidity: Int
    let main: String
    let description: String
    let wind: Double
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
}
