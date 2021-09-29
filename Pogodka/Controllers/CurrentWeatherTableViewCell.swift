//
//  CurrentWeatherTableViewCell.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 24.09.2021.
//

import UIKit

class CurrentWeatherTableViewCell: UITableViewCell {

    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet var weatherIconImageView: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.startAnimating()
        weatherIconImageView.image = nil
    }

    func initalizate(title name: String, temperature: Int, iconName: String, imageLoader: ImageLoaderManager) {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        cityNameLabel.text = name
        weatherIconImageView.contentMode = .scaleAspectFill
        switch temperature {
            case 0: temperatureLabel.text = "0 ºC"
            case -999..<0: temperatureLabel.text = "\(temperature) ºC"
            default: temperatureLabel.text = "+\(temperature) ºC"
        }
        if iconName == "" {
            weatherIconImageView.image = UIImage(named: "DefaultWeatherIcon")
            return
        }
        imageLoader.loadImage(iconName: iconName) { result in
            do { let image = try result.get()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.weatherIconImageView.image = image
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.weatherIconImageView.image = UIImage(named: "DefaultWeatherIcon")
                }
            }
        }
    }
}
