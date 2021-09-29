//
//  ReverseGeocodingModel.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 27.09.2021.
//

struct ReverseGeocodingModel: Codable {
    let localNames: LocalNames?

    enum CodingKeys: String, CodingKey {
        case localNames = "local_names"
    }
}

struct LocalNames: Codable {
    let ru: String?
}
