//
//  ProfileViewController.swift
//  Bookorm
//
//  Created by Student Account  on 3/27/23.
//

import Foundation
import UIKit
import CoreData
// ProfileViewController class, subclass of UIViewController, adopting UITableViewDelegate, UITableViewDataSource, and BookCellSelectionDelegate protocols
class ProfileViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, BookCellSelectionDelegate{
    // IBOutlet properties for UI elements
    @IBOutlet var yourListsLabel: UILabel!
    @IBOutlet var yourBooksLabel: UILabel!
    @IBOutlet var addListButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    // Properties to store book lists and books/
    var bookLists: [BookList] = []
    var book: [Book] = []
    var isFinishedCreatingBook = BookViewController().isFinishedCreatingBook
    // Override viewDidLoad function to configure the view when it's loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        updateLabels()
    }
    
    func updateLabels(){
        yourListsLabel.text = "Your Lists: \(bookLists.count)"
        yourBooksLabel.text = "Your Books: \(book.count)"
    }
    // Function to load data from CoreData/
    func loadData() {
        let defaults = UserDefaults.standard
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if defaults.bool(forKey: "isDownloaded"){
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookList")
            let fetchRequestBook = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
            do {
                let dbItems = try managedContext.fetch(fetchRequest) as! [BookList]
                let dbItemsBook = try managedContext.fetch(fetchRequestBook) as! [Book]
                bookLists.append(contentsOf: dbItems)
                book.append(contentsOf: dbItemsBook)
                tableView.reloadData()
            } catch {}
        } else {
            do{
                bookLists = []
                book = []
                try managedContext.save()
                
                defaults.set(true, forKey: "isDownloaded")
            } catch{}
        }
    }
    // TableView data source methods to configure the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableCell
        cell.listNameLabel.text = bookLists[indexPath.row].title
        // needs different configure function in ListTableCell
        //cell.configure(with: list)
        return cell
    }
    // BookCellSelectionDelegate method to handle cell selection
    func didSelect() {
        performSegue(withIdentifier: "ProfileToDetail", sender: self)
    }
    // Function to handle adding a new list when the "Add List" button is tapped
    @IBAction func addList(_ sender: Any) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let editAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        self.updateLabels()
        editAlert.addTextField { textField in
            textField.text = "New List"
        }
        editAlert.addAction(UIAlertAction(title: "Create List", style: .default, handler: { _ in
            let bookList = NSEntityDescription.insertNewObject(forEntityName: "BookList", into: managedContext) as! BookList
            bookList.title = "New List"
            bookList.title = editAlert.textFields?[0].text ?? ""
            self.bookLists.append(bookList)
            self.tableView.reloadData()
            self.updateLabels()
            do { try managedContext.save()}
            catch{}
        }))
        editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(editAlert, animated: true)
        self.updateLabels()
        self.tableView.reloadData()
        //tableView.scrollToRow(at: IndexPath(item: bookLists.count-1, section: 0), at: .bottom, animated: true)
        do { try managedContext.save()
        } catch {}
    }
    // TableView delegate methods to handle the appearance and interaction of table view cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bookList = bookLists[indexPath.row]
        let alert = UIAlertController(title: bookList.title, message: "Edit Book List", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit List Name", style: .default, handler: { _ in
            self.showListEditSheet(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Delete List", style: .destructive, handler: { _ in
            let myObject = self.bookLists[indexPath.row]
            self.bookLists.remove(at: indexPath.row)
            managedContext.delete(myObject)
            self.tableView.reloadData()
            self.updateLabels()
            do { try managedContext.save()}
            catch{}
        }))
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        
        present(alert, animated: true)
    }
        // action sheet: rename list, delete list
        // message under title: long press on book to delete
    // Function to show an action sheet for editing a list
    func showListEditSheet(indexPath: IndexPath) {
        let bookList = bookLists[indexPath.row]
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let editAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    
        editAlert.addTextField { textField in
            textField.text = bookList.title
        }
        editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        editAlert.addAction(UIAlertAction(title: "Update List", style: .default, handler: { _ in
            bookList.title = editAlert.textFields?[0].text ?? ""
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            do { try managedContext.save()}
            catch{}
        }))
    
        self.present(editAlert, animated: true)
    }
    // Function to update labels when a new book is added
    @IBAction func onAddBook(_ sender: Any) {
        if isFinishedCreatingBook == true {
            self.updateLabels()
        }
    }
    
}
