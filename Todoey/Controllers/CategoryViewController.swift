//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Shivani Aggarwal on 2018-05-02.
//  Copyright © 2018 Shivani Aggarwal. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    let colourArray = ["CBE4F2", "EBF5DF", "D4E6B5", "EBB3A9", "FFE7A8"]
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = UIColor.white
       
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let longPressedGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(_:)))
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if categories?.isEmpty == true {
            print("Setting cell for empty categories")
            cell.textLabel?.text = "No categories added yet."
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
        }
        else {
        
            if let category = categories?[indexPath.row] {
                
                guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
                
                cell.textLabel?.text = category.name
                cell.backgroundColor = categoryColour
                cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
                
            }
            
            cell.addGestureRecognizer(longPressedGestureRecognizer)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self).sorted(byKeyPath: "dateAdded", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting items \(error)")
            }
        }
    }
    
    //MARK: - Add Button Pressed
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text ?? ""
            newCategory.dateAdded = Date()
            newCategory.colour = self.colourArray[Int(arc4random_uniform(5))]
            
            self.save(category: newCategory)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
            
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Edit Items
    
    @objc func longPressedGesture(_ recognizer: UIGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            let longPressedLocation = recognizer.location(in: self.tableView)
            
            if let pressedIndexPath = self.tableView.indexPathForRow(at: longPressedLocation) {
                var textField = UITextField()
                
                let alert = UIAlertController(title: "Edit Category", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Confirm Changes", style: .default) { (action) in
                    if let editedCategory = self.categories?[pressedIndexPath.row] {
                        do {
                            try self.realm.write {
                                editedCategory.name = textField.text ?? ""
                                editedCategory.dateAdded = Date()
                            }
                        } catch {
                            print("Error updating category \(error)")
                        }
                        
                        self.tableView.reloadData()
                    }
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
                    
                }
                
                alert.addAction(action)
                alert.addAction(cancel)
                
                alert.addTextField { (alertText) in
                    textField = alertText
                    alertText.placeholder = "New Category Title"
                }
                
                present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
}
