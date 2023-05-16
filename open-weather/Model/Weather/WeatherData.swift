//
//  WeatherData.swift
//  open-weather
//
//  Created by Manoj Kumar on 11/05/23.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let coord: Coord
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Main: Codable {
    let temp: Double
    let humidity: Int

}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
}

struct Wind: Codable {
    let speed: Double
}

