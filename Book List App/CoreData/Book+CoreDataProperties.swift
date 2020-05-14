//
//  Book+CoreDataProperties.swift
//  Book List App
//
//  Created by Iordan, Raluca on 11/05/2020.
//  Copyright © 2020 Iordan, Raluca. All rights reserved.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var author: String
    @NSManaged public var coverPhotoID: NSNumber?
    @NSManaged public var notes: String
    @NSManaged public var title: String

}
