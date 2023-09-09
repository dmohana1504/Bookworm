//
//  BookViewController.swift
//  Bookorm
//
//  Created by Student Account  on 4/15/23.
//

import Foundation
import UIKit
import CoreData
// BookViewController class, subclass of UIViewController, adopting UIPickerViewDelegate and UIPickerViewDataSource protocols
class BookViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    // IBOutlet properties for UI elements
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var authorTextfield: UITextField!
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var summaryTextfield: UITextField!
    @IBOutlet weak var addNewBookButton: UIButton!
    @IBOutlet weak var cancelNewBookButton: UIButton!
    // Properties to store book lists and books
    var bookLists: [BookList] = []
    var book: [Book] = []
    var isFinishedCreatingBook = false
    // Function to load data from CoreData
    func loadData() {
        let defaults = UserDefaults.standard
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if defaults.bool(forKey: "isDownloaded"){
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookList")
            let fetchRequestBook = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
            do {
                let dbItems = try managedContext.fetch(fetchRequest) as! [BookList]
                bookLists.append(contentsOf: dbItems)
                let dbBookItems = try managedContext.fetch(fetchRequestBook) as! [Book]
                book.append(contentsOf: dbBookItems)
            } catch {}
        } else {
            do{
                bookLists = []
                try managedContext.save()
                defaults.set(true, forKey: "isDownloaded")
            } catch{}
        }
    }
    // Override viewDidLoad function to configure the view when it's loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        listPicker.delegate = self
        listPicker.dataSource = self
        loadData()
        
        // Add a tap gesture recognizer to the view
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    // Function to dismiss the keyboard when tapping outside the text fields
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    // UIPickerViewDataSource methods to configure the list picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bookLists.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bookLists[row].title
    }
    // Function to handle adding a new book when the "Add New Book" button is tapped
    @IBAction func onAddBook(_ sender: Any) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let book = NSEntityDescription.insertNewObject(forEntityName: "Book", into: managedContext) as! Book
        book.title = titleTextfield.text
        book.author = authorTextfield.text
        book.summary = summaryTextfield.text
        self.book.append(book)
        isFinishedCreatingBook = true
        do { try managedContext.save()}
        catch{}
    }
    
    
}
