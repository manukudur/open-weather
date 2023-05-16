//
//  File.swift
//  open-weather
//
//  Created by Manoj Kumar on 08/05/23.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController {
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLable: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var bookMarkIcon: UIBarButtonItem!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var detailView: UIStackView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    var fiveDaysForecastData: [ForecastModel] = []

    var weatherManager = WeatherManager()
    var localStorageManager = LocalStorageManager()
    var weather: WeatherModel!
    var instanceOfHomeVC: HomeViewController! 
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        weatherManager.delegate = self
        weatherManager.delegateForecast = self
        loading(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
        weatherManager.fetchForecast(latitude: latitude, longitude: longitude)
    }

    @IBAction func cancleButtonPressed(_ sender: UIBarButtonItem) {
        if instanceOfHomeVC != nil {
            instanceOfHomeVC.localStorageManager.refreshTableView()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if bookMarkIcon.image! == UIImage(systemName: "bookmark.fill") {
            bookMarkIcon.image = UIImage(systemName: "bookmark")
            localStorageManager.removeCity(cityName: weather.cityName, lat: weather.lat, long: weather.lon)
        } else {
            localStorageManager.addCity(cityName: weather.cityName, lat: weather.lat, long: weather.lon)
            bookMarkIcon.image = UIImage(systemName: "bookmark.fill")
        }
    }
}

extension DetailViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            let cityExists = self.localStorageManager.checkCityExists(cityName: weather.cityName)
            self.bookMarkIcon.image  = UIImage(systemName: cityExists ? "bookmark.fill" : "bookmark")
            self.weather = weather
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.humidityLable.text = String(weather.humidity)
            self.descriptionLabel.text = String(weather.description).capitalized
            self.loading(false)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        loading(false)
    }
}

extension DetailViewController: ForecastManagerDelegate {
    func didUpdateForecast(_ weatherManager: WeatherManager, forecast: [FiveDaysForecast]) {
        DispatchQueue.main.async {
            forecast.forEach { item in
                self.fiveDaysForecastData.append(ForecastModel(conditionId: item.weather[0].id, temperature: item.main.temp, humidity: item.main.humidity, main: item.weather[0].main, description: item.weather[0].description, wind: item.wind.speed, date: item.dt_txt))
            }
            self.forecastCollectionView.reloadData()
        }
    }
    
    func didForecastFailWithError(error: Error) {
        print(error)
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fiveDaysForecastData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastDetails", for: indexPath) as! ForecastCollectionViewCell
        let forecast = fiveDaysForecastData[indexPath.row]
        cell.temperatureLabel.text = String(forecast.temperatureString)
        cell.conditionImageView.image = UIImage(systemName: forecast.conditionName)
        cell.humidityLable.text = String(forecast.humidity)
        cell.descriptionLabel.text = forecast.description.capitalized
        cell.dateLabel.text = forecast.date
        return cell
    }
}

extension DetailViewController {
    func loading(_ state: Bool) {
        loadingIndicator.isHidden = !state
        state ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        navigationBar.isHidden = state
        detailView.isHidden = state
        
    }
}
