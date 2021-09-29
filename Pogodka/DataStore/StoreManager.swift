//
//  StoreManager.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 29.09.2021.
//

import CoreData
import UIKit

class StoreManager {

    private var cities: [NSManagedObject] = []
    private var managedContext: NSManagedObjectContext!
    private var appDelegate: AppDelegate?

    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.appDelegate = appDelegate
        managedContext = self.appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CitiesName")
        do {
            cities = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func citiesCount() -> Int {
        return cities.count
    }

    func getCityName(at: Int) -> String? {
        let city = cities[at]
        if let cityName = city.value(forKey: "name") as? String {
            return cityName
        }
        return nil
    }

    func getCitiesList() -> [String] {
        var citiesList: [String] = []
        for city in cities {
            if let cityName = city.value(forKey: "name") as? String {
                citiesList.append(cityName)
            }
        }
        return citiesList
    }

    func addCity(name: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: "CitiesName",
                                                      in: managedContext) else {
            return
        }
        let city = NSManagedObject(entity: entity, insertInto: managedContext)
        city.setValue(name, forKey: "name")
        do {
            try managedContext.save()
            cities.append(city)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteCity(at: Int) {
        managedContext.delete(cities[at])
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
