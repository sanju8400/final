//
//  ViewController.swift
//  Sanjay_Sharma_FE_8890604
//
//  Created by user238626 on 4/13/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var discoverButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatherInfo: UITextView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request location authorization
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Setup mapView
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        // Fetch weather data
        fetchWeatherData()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(region, animated: true)
            
            // Add a pin for the current location
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Helper Methods
    
    func fetchWeatherData() {
        guard let currentLocation = locationManager.location else {
            print("Error: Unable to retrieve current location.")
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed with error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found.")
                return
            }
            
            // Extract city name from placemark
            if let city = placemark.locality {
                print("Current city: \(city)")
                // Call API method with city name
                self.makeAPICalltoGetData(for: city)
            } else {
                print("City name not found.")
            }
        }
    }
    
    func makeAPICalltoGetData(for cityName: String) {
        // Create URL using city name
        guard let encodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCityName)&appid=d3f0956caa7ad29a06e029f9a9cb7c0e") else {
            return
        }
        
        
        // Fetch JSON data from server using URL
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            // If data received from server, proceed
            if let data = data {
                do {
                    print(String(data: data, encoding: .utf8) ?? "No data")
                    
                    // Decode data using Weather struct
                    let jsonData = try JSONDecoder().decode(Weather.self, from: data)
                    
                    // Pass weather data to update labels on view thread
                    DispatchQueue.main.async {
                        self.updateWeatherInfo(jsonData)
                    }
                } catch {
                    print("Error decoding data.")
                }
            } else {
                print("Error getting data from server.")
            }
        }
        task.resume()
    }
    
    
    func updateWeatherInfo(_ weather: Weather) {
        let cityName = weather.name
        let temperature = weather.main.temp
        let temperatureInCelsius = temperature - 273.15 // Convert Kelvin to Celsius
        let humidity = weather.main.humidity
        let windSpeed = weather.wind.speed
        let windSpeedInKilometersPerHour = windSpeed * 3.6 // Convert m/s to km/h
        
        let weatherText = """
             \(String(format: "%.1f", temperatureInCelsius))°C
            Humidity: \(humidity)%
            Wind: \(String(format: "%.1f", windSpeedInKilometersPerHour)) km/h
            """
        
        weatherInfo.text = weatherText
    }
    
}


