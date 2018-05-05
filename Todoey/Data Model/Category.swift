//
//  Category.swift
//  Todoey
//
//  Created by Shivani Aggarwal on 2018-05-05.
//  Copyright © 2018 Shivani Aggarwal. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
