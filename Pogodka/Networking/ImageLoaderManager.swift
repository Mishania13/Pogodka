//
//  ImageLoaderManager.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 27.09.2021.
//
import UIKit

class ImageLoaderManager {

    private var loadedImages = [URL: UIImage]()

    func loadImage(iconName: String, _ complition: @escaping(Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconName)@2x.png") else {return}
        if let image = loadedImages[url] {
            complition(.success(image))
        }

        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                complition(.success(image))
                return
            }
            if let error = error {
                complition(.failure(error))
            }
        }
        task.resume()
    }
}
