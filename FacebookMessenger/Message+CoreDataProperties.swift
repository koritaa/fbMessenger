//
//  Message+CoreDataProperties.swift
//  FacebookMessenger
//
//  Created by Korita on 08.08.17.
//  Copyright © 2017 Korita. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var text: String?
    @NSManaged public var time: NSDate?
    @NSManaged public var isSender: Bool
    @NSManaged public var friend: Friend?

}
