//
//  ViewController.swift
//  open-weather
//
//  Created by Manoj Kumar on 08/05/23.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCitiesTextField: UITextField!
    @IBOutlet weak var floatMapButton: UIButton!

    
    var savedCities: [City] = []
    var weatherManager = WeatherManager()
    var localStorageManager = LocalStorageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        weatherManager.delegate = self
        localStorageManager.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPress)
        
        setFloatMapButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        localStorageManager.refreshTableView()
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                displayAlert(indexPath[1])
            }
        }
    }
    
    func displayAlert(_ forIndex: Int) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure to delete this city ?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.destructive, handler: { action in
            self.localStorageManager.deleteCity(index: forIndex)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

extension HomeViewController: UITextFieldDelegate {
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        addCitiesTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCitiesTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = addCitiesTextField.text {
            if localStorageManager.checkCityExists(cityName: city) {
                let alert = UIAlertController(title: "Oops..!", message: "City already exists in the list", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true)
            } else {
                weatherManager.fetchWeather(cityName: city)
            }
        }
        addCitiesTextField.text = ""
        
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesList", for: indexPath)
        cell.textLabel?.text = String(savedCities[indexPath.row].cityName)
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "detailView", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailView" {
            let latitude = savedCities[sender as! Int].lat
            let longitude = savedCities[sender as! Int].long
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.latitude = latitude
            destinationVC.longitude = longitude
            destinationVC.instanceOfHomeVC = self
        }
    }
}

extension HomeViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.localStorageManager.addCity(cityName: weather.cityName, lat: weather.lat, long: weather.lon)
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}

extension HomeViewController: LocalStorageDelegate {
    func updateTable(_ localStorageManager: LocalStorageManager, _ cities: [City]) {
        savedCities = cities
        tableView.reloadData()
    }
}

extension HomeViewController {
    func setFloatMapButton() {
        floatMapButton.imageView?.image = UIImage(systemName: "map")
        floatMapButton.layer.cornerRadius = 25
        floatMapButton.layer.masksToBounds = true
    }
}

