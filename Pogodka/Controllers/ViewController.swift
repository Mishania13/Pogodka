//
//  ViewController.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 21.09.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var weatherImageView: UIImageView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var activitiIndicator: UIActivityIndicatorView!
    @IBOutlet private var mainCityViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var mainCityView: UIView!

    private let locationManager = CLLocationManager()
    private let imageLoader = ImageLoaderManager()
    private let storeManger = StoreManager()

    private let refreshControl = UIRefreshControl()
    private var lastUpdateTime = Date()
    private var autoUpdateTimer: Timer!

    private var cityWeatherByName: CurrentWeatherModel?
    private var citiesWeather: [CurrentWeatherModel] = []
    private var mainCityName: String?
    private let tableViewCellIdentifire = "CurrentWeatherTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        cityNameLabel.text = nil
        temperatureLabel.text = nil
        activitiIndicator.hidesWhenStopped = true

        tableView.register(UINib(nibName: tableViewCellIdentifire, bundle: nil),
                                forCellReuseIdentifier: tableViewCellIdentifire)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.layer.zPosition = tableView.layer.zPosition - 1

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        searchBar.delegate = self
        searchBar.placeholder = "Добавить город"

        hideKeyboardOnTap()
        loadCitiesInfo()

        self.title = "Погода сейчас"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        changeMainCityViewState(isOpen: mainCityName != nil)
    }

    private func loadCitiesInfo() {
        for city in storeManger.getCitiesList() {
            DispatchQueue.global().sync {
                addCityWeather(cityName: city)
            }
        }
    }

    private func addCityWeather(cityName: String, needLoadingView: Bool = false) {
        if needLoadingView {
            DispatchQueue.main.async {
                self.showLoading()
            }
        }
        NetworkManager.fetchingWeather(endpoint: Endpoints.cityCurrentWeather(city: cityName),
                                       fetchType: .weather,
                                       reusltType: CurrentWeatherModel.self) { result in
            DispatchQueue.main.async {
                self.hideLoading()
                self.refreshControl.endRefreshing()
            }
            do {
                self.lastUpdateTime = Date()
                let data = try result.get()
                if let name = data.name,
                   !self.storeManger.getCitiesList().contains(name) {
                        self.storeManger.addCity(name: name)
                }
                self.citiesWeather.append(data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    if String(describing: error) == "wrongCity" {
                        self.showAlert(title: "Неверный город", message: "Название города \"\(cityName)\" введено с ошибками или такого города не существует")
                    } else {
                        self.showAlert(title: "Ошибка", message: "При загрузке данных произошла ошибка")
                    }
                }
            }
        }
    }

    private func mainCitySetting(cityData: CurrentWeatherModel) {
        DispatchQueue.main.async {
            self.mainCityName = cityData.name
            self.changeMainCityViewState(isOpen: true, animated: true)
            self.activitiIndicator.startAnimating()
            self.cityNameLabel.text = cityData.name
            let temp = Int(cityData.main?.temp?.rounded() ?? 0)
            switch temp {
            case 0: self.temperatureLabel.text = "0 ºC"
            case -999..<0: self.temperatureLabel.text = "\(temp) ºC"
            default: self.temperatureLabel.text = "+\(temp) ºC"
            }
        }
        imageLoader.loadImage(iconName: cityData.weather?.first?.icon ?? "") { result in
            do {
                let image = try result.get()
                DispatchQueue.main.async {
                    self.weatherImageView.image = image
                    self.changeMainCityViewState(isOpen: true)
                    self.activitiIndicator.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    self.weatherImageView.image = UIImage(named: "DefaultWeatherIcon")
                    self.changeMainCityViewState(isOpen: true)
                    self.activitiIndicator.stopAnimating()
                }
            }
        }
    }

    private func useCustomMainCity() {
        let alert = UIAlertController(title: "Предпочитаемая локация", message: "Введите название города в котором находитесь", preferredStyle: .alert)
        alert.addTextField()
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text, text.count >= 2 {
                DispatchQueue.main.async {
                    self.showLoading()
                }
                NetworkManager.fetchingWeather(endpoint: Endpoints.cityCurrentWeather(city: text), fetchType: .weather, reusltType: CurrentWeatherModel.self) { result in
                    DispatchQueue.main.async {
                        self.hideLoading()
                    }
                    do {
                        let data = try result.get()
                        DispatchQueue.main.async {
                            self.mainCitySetting(cityData: data)
                            self.activitiIndicator.stopAnimating()
                        }
                    } catch {
                        if String(describing: error) == "wrongCity" {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Неверный город", message: "Название города \"\(text)\" введено с ошибками") {
                                    self.useCustomMainCity()
                                }
                            }
                        } else {
                            self.showAlert(title: "Ошибка сети", message: "Проблемы с подключением к сервису")
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Неверный город", message: "Неккоректное название города")
                    self.useCustomMainCity()
                }
            }
        }
        let cancleAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            DispatchQueue.main.async {
                self.activitiIndicator.stopAnimating()
                self.changeMainCityViewState(isOpen: false, animated: true)
            }
        }
        alert.addAction(cancleAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    private func changeMainCityViewState(isOpen: Bool, animated: Bool = false) {
        let duration = animated ? 0.3 : 0
        let value: CGFloat = isOpen ? 0.3 : 0
        self.mainCityViewHeightConstraint.constant = self.view.frame.height * value
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func removeCityFromList(at: Int) {
        citiesWeather.remove(at: at)
        storeManger.deleteCity(at: at)
    }

    private func autoUpdateData() {
        autoUpdateTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { timer in
            self.citiesWeather = []
            self.loadCitiesInfo()
        }
    }

    @objc private func refresh(_ sender: Any) {
        if lastUpdateTime.allowUpdate(updateIntervalSec: 40) {
            citiesWeather = []
            loadCitiesInfo()
            autoUpdateTimer.invalidate()
            autoUpdateData()
        } else {
            refreshControl.endRefreshing()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        citiesWeather.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifire) as! CurrentWeatherTableViewCell
        let cityInfo = citiesWeather[indexPath.row]
        cell.initalizate(title: cityInfo.name ?? "Город",
                         temperature: Int(cityInfo.main?.temp?.rounded() ?? 0),
                         iconName: cityInfo.weather?.first?.icon ?? "",
                         imageLoader: imageLoader)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeCityFromList(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let forecastVC = CityForecastViewController()
        let city = citiesWeather[indexPath.row]
        guard let name = city.name,
              let lat = city.coord?.lat,
              let lon = city.coord?.lon else {return}
        forecastVC.initilizate(cityName: name, imageLoader: imageLoader, iconName: city.weather?.first?.icon ?? "", latitude: lat, longitude: lon)
        self.navigationController?.pushViewController(forecastVC, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count > 2, !storeManger.getCitiesList().map({$0.capitalized}).contains(text.capitalized) {
            addCityWeather(cityName: text, needLoadingView: true)
            searchBar.text = nil
        }
        view.endEditing(true)
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            useCustomMainCity()
            return
        }
        NetworkManager.fetchGeocode(latitude: Double(locationValue.latitude),
                                    longitude: Double(locationValue.longitude)) { result in
            do {
                let cityName = try result.get()
                NetworkManager.fetchingWeather(endpoint: Endpoints.cityCurrentWeather(city: cityName),
                                               fetchType: .weather,
                                               reusltType: CurrentWeatherModel.self) { result in
                    do {
                        let data = try result.get()
                        self.mainCitySetting(cityData: data)
                    } catch {
                        self.useCustomMainCity()
                    }
                }
            } catch {
                self.useCustomMainCity()
            }
        }
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("resume")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            useCustomMainCity()
        default:
            return
        }
    }
}
