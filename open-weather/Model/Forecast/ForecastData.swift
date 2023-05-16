//
//  ForecastData.swift
//  open-weather
//
//  Created by Manoj Kumar on 15/05/23.
//

import Foundation

struct ForecastData: Codable {
    let list: [FiveDaysForecast]
}

struct FiveDaysForecast: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let dt_txt: String
}
