//
//  Book+CoreDataClass.swift
//  Book List App
//
//  Created by Iordan, Raluca on 11/05/2020.
//  Copyright © 2020 Iordan, Raluca. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Book)
public class Book: NSManagedObject {
    var photoURL: URL {
        assert(coverPhotoID != nil, "No photo ID set")
        let filename = "Photo-\(coverPhotoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoURLFromFirebase: String = ""
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        do {
            try FileManager.default.removeItem(at: photoURL)
        } catch {
            print("Error removing file: \(error)")
        }
    }
}
