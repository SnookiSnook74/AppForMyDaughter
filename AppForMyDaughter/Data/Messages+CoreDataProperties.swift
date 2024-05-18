//
//  Messages+CoreDataProperties.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//
//

import Foundation
import CoreData

@objc(Messages)
public class Messages: NSManagedObject {}

extension Messages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Messages> {
        return NSFetchRequest<Messages>(entityName: "Messages")
    }

    @NSManaged public var text: String?
    @NSManaged public var sender: String?

}

extension Messages : Identifiable {

}
