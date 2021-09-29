//
//  CitiesName+CoreDataProperties.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 29.09.2021.
//
//

import Foundation
import CoreData


extension CitiesName {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CitiesName> {
        return NSFetchRequest<CitiesName>(entityName: "CitiesName")
    }

    @NSManaged public var name: String?

}

extension CitiesName : Identifiable {

}
