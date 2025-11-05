//
//  User+CoreDataProperties.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 8/6/25.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var emailAddress: String?
    @NSManaged public var password: String?
    @NSManaged public var fullName: String?
    
    @NSManaged public var foodItems:NSSet?
    

}
extension User {

    // ⭐ Ensure these methods are present and correct! ⭐
    @objc(addFoodItemsObject:)
    @NSManaged public func addToFoodItems(_ value: FoodItem)

    @objc(removeFoodItemsObject:)
    @NSManaged public func removeFromFoodItems(_ value: FoodItem)

    @objc(addFoodItems:)
    @NSManaged public func addToFoodItems(_ values: NSSet)

    @objc(removeFoodItems:)
    @NSManaged public func removeFromFoodItems(_ values: NSSet)

}

extension User : Identifiable {

}
