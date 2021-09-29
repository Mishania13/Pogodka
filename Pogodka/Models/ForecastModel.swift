//
//  ForecastModel.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 22.09.2021.
//

struct ForecastModel: Codable {

    let lat: Double?
    let lon: Double?
    let unixTimezone: String?
    let timezoneOffset: Int?
    let current: CurrentModel?
    let hourly: [CurrentModel]?
    let daily: [DailyModel]?

    enum CodingKeys: String, CodingKey {
        case lat, lon
        case unixTimezone = "timezone"
        case timezoneOffset = "timezone_offset"
        case current, hourly, daily
    }
}

struct CurrentModel: Codable {

    let dt: Int?
    let temp, feelsLike: Double?
    let pressure, humidity: Int?
    let clouds, visibility: Int?
    let windSpeed: Double?
    let windDeg: Int?
    let weather: [ForecastWeatherModel]?

    enum CodingKeys: String, CodingKey {
        case dt, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case clouds, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
    }
}

struct ForecastWeatherModel: Codable {

    let id: Int?
    let main: String
    let weatherDescription: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

struct DailyModel: Codable {

    let dt: Int?
    let temp: TempModel?
    let feelsLike: FeelsLikeModel?
    let pressure, humidity: Int?
    let dewPoint, windSpeed: Double?
    let windDeg: Int?
    let weather: [Weather]?
    let clouds: Int?

    enum CodingKeys: String, CodingKey {
        case dt
        case temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather, clouds
    }
}

struct FeelsLikeModel: Codable {

    let day, night, evening, morning: Double?

    enum CodingKeys: String, CodingKey {
        case day, night
        case evening = "eve"
        case morning = "morn"
    }
}

struct TempModel: Codable {

    let day, min, max, night, evening, morning: Double?

    enum CodingKeys: String, CodingKey {
        case day, min, max, night
        case evening = "eve"
        case morning = "morn"
    }
}
