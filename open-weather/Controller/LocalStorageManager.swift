//
//  LocalStorageManager.swift
//  open-weather
//
//  Created by Manoj Kumar on 12/05/23.
//

import Foundation

protocol LocalStorageDelegate {
    func updateTable(_ localStorageManager: LocalStorageManager, _ cities: [City])
}

struct LocalStorageManager {
    
    var delegate: LocalStorageDelegate?
    
    func saveCities (_ cities: [City]) {
        let citiesData = try! JSONEncoder().encode(cities)
        UserDefaults.standard.set(citiesData, forKey: "savedCities")
        self.delegate?.updateTable(self, cities)
    }
    
    func addCity(cityName: String, lat: Double, long: Double) {
        var citiesArray: [City] = getCities()!
        citiesArray.append(City(cityName: cityName, lat: lat, long: long))
        saveCities(citiesArray)
    }
    
    func removeCity(cityName: String, lat: Double, long: Double) {
        var citiesArray: [City] = getCities()!
        if let cityIndex = citiesArray.firstIndex(where: { $0.cityName.lowercased() == cityName.lowercased() }) {
            citiesArray.remove(at: cityIndex)
        }
        saveCities(citiesArray)
    }

    func getCities() -> [City]? {
        let citiesData = UserDefaults.standard.data(forKey: "savedCities")
        if citiesData != nil {
            let citiesArray = try! JSONDecoder().decode([City].self, from: citiesData!)
            return citiesArray
        }
        return []
    }
    
    func deleteCity(index: Int) {
        var citiesArray: [City] = getCities()!
        citiesArray.remove(at: index)
        saveCities(citiesArray)
    }
    
    func checkCityExists(cityName: String) -> Bool {
        let citiesArray: [City] = getCities()!
        if let _ = citiesArray.firstIndex(where: { $0.cityName.lowercased() == cityName.lowercased() }) {
            return true
        }
        return false
    }
    
    func refreshTableView() {
        let citiesArray: [City] = getCities()!
        self.delegate?.updateTable(self, citiesArray)
    }
}
