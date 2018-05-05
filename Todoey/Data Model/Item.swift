//
//  Item.swift
//  Todoey
//
//  Created by Shivani Aggarwal on 2018-05-05.
//  Copyright © 2018 Shivani Aggarwal. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
 
