//
//  BookTableCell.swift
//  Bookorm
//
//  Created by Student Account  on 3/27/23.
//

import UIKit
// BookCollectionCell class, subclass of UICollectionViewCell
class BookCollectionCell: UICollectionViewCell {
    // IBOutlet properties for UI elements within the cell
    @IBOutlet weak var bookLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    // Property to store the book's rating
    var rating: Int16 = 0
}

// Protocol for handling book cell selection
protocol BookCellSelectionDelegate {
    // Function called when a book cell is selected
    func didSelect()
}
