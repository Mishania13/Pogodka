//
//  NetworkManager.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 22.09.2021.
//

import Foundation

struct NetworkManager {

    static func fetchingWeather<T: Codable>(endpoint: String, fetchType: FetchType, reusltType: T.Type, _ complition: @escaping(Result<T, Error>) -> Void) {
        DispatchQueue.global().async {
            let url = URLBuilder.build(endpoint: endpoint, fetchType: fetchType)
            guard let url = url else {return}
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    complition(.failure(error))
                }
                if let data = data {
                    if let json = parseJSON(data: data, responseType: T.self) {
                        complition(.success(json))
                    } else if let _ = parseJSON(data: data, responseType: WeatherErrorModel.self) {
                        complition(.failure(CurrentWeatherErrors.wrongCity))
                    }
                }
            }
            task.resume()
        }
    }

    static func fetchGeocode(latitude: Double, longitude: Double, _ complition: @escaping(Result<String, Error>) -> Void) {
        DispatchQueue.global().async {
            let url = URLBuilder.build(endpoint: Endpoints.geocodingCoordinate(cityLatitude: latitude, cityLongitude: longitude), fetchType: .reverseGeocode)
            guard let url = url else {return}
            let task = URLSession.shared.dataTask(with: url) {data, _, error in
                if let error = error {
                    complition(.failure(error))
                }
                if let data = data {
                    if let json = parseJSON(data: data, responseType: [ReverseGeocodingModel].self) {
                        complition(.success(json.first?.localNames?.ru ?? "Москва"))
                    }
                }
            }
            task.resume()
        }
    }

    static private func parseJSON<T: Codable>(data: Data, responseType: T.Type) -> T? {
        let decoder = JSONDecoder()
        if let json = try? decoder.decode(T.self, from: data) {
            return json
        }
        return nil
    }
}
