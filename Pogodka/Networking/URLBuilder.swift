//
//  URLBuilder.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 21.09.2021.
//

import Foundation

class URLBuilder {

    static func build(endpoint: String, fetchType: FetchType) -> URL? {
        var components = URLComponents()
        components.scheme = BaseURLs.scheme.rawValue
        components.host = BaseURLs.baseUrl.rawValue

        switch fetchType {
        case .reverseGeocode:
            components.path = BaseURLs.mainPathGeocoding.rawValue
            components.query = endpoint + BaseURLs.apiKey()
        default:
            components.path = BaseURLs.mainPath.rawValue + fetchType.rawValue
            components.query = endpoint + BaseURLs.apiKey() + BaseURLs.setCelsium.rawValue + BaseURLs.setLanguege.rawValue
        }
        return components.url
    }
}

enum BaseURLs: String {
    
    case scheme = "https"
    case baseUrl = "api.openweathermap.org"
    case mainPath = "/data/2.5/"
    case setCelsium = "&units=metric"
    case setLanguege = "&lang=ru"
    case mainPathGeocoding = "/geo/1.0/reverse"

    static func apiKey() -> String {
        return ("&appid=\(Bundle.main.object( forInfoDictionaryKey: "APIKey") as! String)")
    }
}

struct Endpoints {

    static func cityCurrentWeather(city: String) -> String {
        return "q=\(city)"
    }
    static func cityForecast(cityLatitude: Double, cityLongitude: Double) -> String {
        return "lat=\(cityLatitude)&lon=\(cityLongitude)&exclude=minutely,current,hourly"
    }
    static func geocodingCoordinate(cityLatitude: Double, cityLongitude: Double) -> String {
        return "lat=\(cityLatitude)&lon=\(cityLongitude)"
    }
}

enum FetchType: String {

    case weather = "weather"
    case forecast = "onecall"
    case reverseGeocode = "reverse"
}
