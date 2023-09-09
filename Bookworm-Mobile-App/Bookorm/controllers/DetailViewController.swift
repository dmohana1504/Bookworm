//
//  DetailViewController.swift
//  Bookorm
//
//  Created by Student Account  on 3/27/23.
//

import Foundation
import UIKit

// DetailViewController class, subclass of UIViewController
class DetailViewController: UIViewController {
    // IBOutlet properties for UI elements
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var addRating: UIButton!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var notYetRatedLabel: UILabel!
    // Properties for book rating and book object
    var rating: Int = 0
    var book: Book!
    // Private function to update the UI with book information
    private func updateUI() {
        titleLabel.text = book?.title
        authorLabel.text = book?.author
        summaryTextView.text = book?.summary
    }
    // Override viewDidLoad function to configure the view when it's loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryTextView.isEditable = false
        summaryTextView.isSelectable = false
        dispRatingStars(rating: rating)
        updateUI()
        // Add swipe gesture recognizer to dismiss the view
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_ :)))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    // Function to display rating stars based on the current rating
    func dispRatingStars(rating: Int){
        // A series of if-else statements to show/hide star images and the "not yet rated" label
            // according to the book's rating
        if (book.rating == 1) {
            self.notYetRatedLabel.isHidden = true
            self.star1.isHidden = false
            self.star2.isHidden = true
            self.star3.isHidden = true
            self.star4.isHidden = true
            self.star5.isHidden = true
        } else if (book.rating == 2) {
            self.notYetRatedLabel.isHidden = true
            self.star1.isHidden = false
            self.star2.isHidden = false
            self.star3.isHidden = true
            self.star4.isHidden = true
            self.star5.isHidden = true
        } else if (book.rating == 3){
            self.notYetRatedLabel.isHidden = true
            self.star1.isHidden = false
            self.star2.isHidden = false
            self.star3.isHidden = false
            self.star4.isHidden = true
            self.star5.isHidden = true
        } else if (book.rating == 4){
            self.notYetRatedLabel.isHidden = true
            self.star1.isHidden = false
            self.star2.isHidden = false
            self.star3.isHidden = false
            self.star4.isHidden = false
            self.star5.isHidden = true
        } else if (book.rating == 5){
            self.notYetRatedLabel.isHidden = true
            self.star1.isHidden = false
            self.star2.isHidden = false
            self.star3.isHidden = false
            self.star4.isHidden = false
            self.star5.isHidden = false
        }else {
            self.notYetRatedLabel?.isHidden = false
            self.star1?.isHidden = true
            self.star2?.isHidden = true
            self.star3?.isHidden = true
            self.star4?.isHidden = true
            self.star5?.isHidden = true
        }
    }
    // Function to handle adding a rating for the book when the "Add Rating" button is tapped
    @IBAction func onAddRating(_ sender: UIButton) {
        // Get the managed object context for CoreData
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // Create UIAlertAction objects for rating options and cancel action
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel) { (action) in
            }
            let rate1 = UIAlertAction(title: "1",
                                      style: .default) { (action) in
                self.rating = 1
                self.book.rating = 1
                self.dispRatingStars(rating: self.rating)
            }
            let rate2 = UIAlertAction(title: "2",
                                      style: .default) { (action) in
                self.rating = 2
                self.book.rating = 2
                self.dispRatingStars(rating: self.rating)
            }
            let rate3 = UIAlertAction(title: "3",
                                      style: .default) { (action) in
                self.rating = 3
                self.book.rating = 3
                self.dispRatingStars(rating: self.rating)
            }
            let rate4 = UIAlertAction(title: "4",
                                      style: .default) { (action) in
                self.rating = 4
                self.book.rating = 4
                self.dispRatingStars(rating: self.rating)
            }
            let rate5 = UIAlertAction(title: "5",
                                      style: .default) { (action) in
                self.rating = 5
                self.book.rating = 5
                self.dispRatingStars(rating: self.rating)
            }
        // Create UIAlertController to present the rating options
            let alert = UIAlertController(title: "Add Rating",
                                          message: "Please Rate The Book.",
                                          preferredStyle: .alert)
        // Add actions to the alert controller
            alert.addAction(cancelAction)
            alert.addAction(rate1)
            alert.addAction(rate2)
            alert.addAction(rate3)
            alert.addAction(rate4)
            alert.addAction(rate5)
        // Present the alert controller
            self.present(alert, animated: true) {
            }
        // Save changes to the managed object context
        do {
            try managedContext.save()
        } catch {}
    }
    // Function to handle swipe gesture to dismiss the view
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            performSegue(withIdentifier: "detailToHome", sender: self)
        }
    }
    // Prepare for segue to the main view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // Check if the segue identifier is "detailToHome"
        if segue.identifier == "detailToHome" {
            // Get the destination MainViewController
            let controller = segue.destination as! MainViewController
            // Reload the book collection view data
            controller.bookCollectionView?.reloadData()
            //controller.dispRatingStars(rating: Int(selectedBook.rating))
        }
        // Save changes to the managed object context
        do {
            try managedContext.save()
        } catch{}
    }
}
