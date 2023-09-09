//
//  ListTableCell.swift
//  Bookorm
//
//  Created by Student Account  on 4/2/23.
//

import UIKit
import CoreData
// ListTableCell class, subclass of UITableViewCell
class ListTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    // IBOutlet properties for UI elements within the cell
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    // Array of Book objects
    var book: [Book] = []
    // Delegate for BookCellDelegate protocol
    var delegate: BookCellDelegate?
    // Function to load data from CoreData/
    func loadData() {
        let defaults = UserDefaults.standard
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if defaults.bool(forKey: "isDownloaded"){
            let fetchRequestBook = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
            do {
                let dbBookItems = try managedContext.fetch(fetchRequestBook) as! [Book]
                book.append(contentsOf: dbBookItems)
            } catch {}
        } else {
            do{
                book = []
                try managedContext.save()
                defaults.set(true, forKey: "isDownloaded")
            } catch{}
        }
    }
    // awakeFromNib function to setup collectionView delegate and dataSource
    override func awakeFromNib() {
        super.awakeFromNib()
        loadData()
        
        collectionView.delegate = self as UICollectionViewDelegate
        collectionView.dataSource = self as UICollectionViewDataSource
    }
    
    // Function to return the number of items in the collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book.count
    }
    // Function to create and configure the collectionView cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        loadData()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCollectionCell
        let book = book[indexPath.row]
        
        cell.bookLabel.text = book.title
        return cell
    }
    
    // Function to handle didSelectItemAt event in the collectionView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
// Protocol for handling book cell interactions within the ListTableCell
protocol BookCellDelegate: AnyObject {
    func collectionView(collectionviewcell: BookCollectionCell?, index: Int, didTappedInTableViewCell: ListTableCell)
    func didSelect()
    
}
