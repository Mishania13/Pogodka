//
//  CityForecastViewController.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 28.09.2021.
//

import UIKit

class CityForecastViewController: UIViewController {

    private var cityName: String!
    private var imageLoader: ImageLoaderManager!
    private var tableView = UITableView()
    private let tableViewCellIdentifire = "CurrentWeatherTableViewCell"
    private let refreshControl = UIRefreshControl()
    private var latitude: Double = 0
    private var longitude: Double = 0
    private var lastUpdateTime = Date()
    private var forecast: ForecastModel? {
        didSet {
            DispatchQueue.main.async {
                self.hideLoading()
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame = view.frame
        view.addSubview(tableView)
        tableView.register(UINib(nibName: tableViewCellIdentifire, bundle: nil), forCellReuseIdentifier: tableViewCellIdentifire)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.layer.zPosition = tableView.layer.zPosition - 1

        self.navigationController?.navigationBar.topItem?.title = " "
    }

    func initilizate(cityName: String, imageLoader: ImageLoaderManager, iconName: String, latitude: Double, longitude: Double) {
        title = cityName
        self.imageLoader = imageLoader
        self.latitude = latitude
        self.longitude = longitude
        loadForecast()
    }

    @objc private func refresh(_ sender: Any) {
        if lastUpdateTime.allowUpdate(updateIntervalSec: 40) {
            loadForecast()
        } else {
            refreshControl.endRefreshing()
        }

    }

    func weekDayFrom(unixDate: Int?, timezoneOffset: Int?) -> String {
        guard let date = unixDate, let offSet = timezoneOffset else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        if formatter.string(from: Date()) == formatter.string(from: Date(timeIntervalSince1970: Double(date + offSet))) {
            return "Сегодня"
        }
        let day = Calendar.current.component(.weekday, from: Date(timeIntervalSince1970: Double(date + offSet))) - 1
        switch day {
        case 1: return "Понедельник"
        case 2: return "Вторник"
        case 3: return "Среда"
        case 4: return "Четверг"
        case 5: return "Пятница"
        case 6: return "Суббота"
        case 0: return "Воскресенье"
        default:
            return ""
        }
    }

    private func loadForecast() {
        showLoading()
        NetworkManager.fetchingWeather(endpoint: Endpoints.cityForecast(cityLatitude: latitude, cityLongitude: longitude),
                                       fetchType: .forecast,
                                       reusltType: ForecastModel.self) { result in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            do {
                self.lastUpdateTime = Date()
                let data = try result.get()
                self.forecast = data
            } catch {
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }

    }
}

extension CityForecastViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecast?.daily?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifire) as! CurrentWeatherTableViewCell
        cell.initalizate(title: weekDayFrom(unixDate: forecast?.daily?[indexPath.row].dt, timezoneOffset: forecast?.timezoneOffset),
                         temperature: Int(forecast?.daily?[indexPath.row].temp?.day?.rounded() ?? 0),
                         iconName: forecast?.daily?[indexPath.row].weather?.first?.icon ?? "",
                         imageLoader: imageLoader)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cityName
    }
}
