//
//  ViewController.swift
//  Todoey
//
//  Created by Shivani Aggarwal on 2018-04-29.
//  Copyright © 2018 Shivani Aggarwal. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems : Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()

    }
    
    override func viewWillAppear(_ animated: Bool) {

        title = selectedCategory?.name
    
        guard let colourHex = selectedCategory?.colour else {fatalError()}
        
        updateNavBar(withHexCode: colourHex)
    }

    
    override func willMove(toParentViewController parent: UIViewController?) {
        
        updateNavBar(withHexCode: "1A237E")
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let longPressedGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(_:)))
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if todoItems?.isEmpty == true {
            cell.textLabel?.text = "No items added yet."
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
        }
        
        else {
        
            cell.addGestureRecognizer(longPressedGestureRecognizer)
            
            if let item = todoItems?[indexPath.row] {
                cell.textLabel?.text = item.title
                
                if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count) * 0.35) {
                    
                    cell.backgroundColor = colour
                    cell.textLabel?.textColor =  ContrastColorOf(colour, returnFlat: true)
                }
                
                cell.accessoryType = item.done ? .checkmark : .none
            }
            else {
                cell.textLabel?.text = "No Items Added"
            }
        
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Button", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen when user pressed Add Item button on UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text ?? ""
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
            
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
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
                
                let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Confirm Changes", style: .default) { (action) in
                    if let editedItem = self.todoItems?[pressedIndexPath.row] {
                        do {
                            try self.realm.write {
                                editedItem.title = textField.text ?? ""
                                editedItem.dateCreated = Date()
                            }
                        } catch {
                            print("Error updating item \(error)")
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
                    alertText.placeholder = "New Item Title"
                }
                
                present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting items \(error)")
            }
        }
    }
    
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
}





