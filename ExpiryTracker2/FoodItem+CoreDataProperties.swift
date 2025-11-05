//
//  FoodItem+CoreDataProperties.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 8/9/25.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var quantity: String?
    @NSManaged public var expirationDate: Date?
    @NSManaged public var imageName: String?
    @NSManaged public var addedDate: Date?
    @NSManaged public var owner: User?

}

extension FoodItem : Identifiable {

}
