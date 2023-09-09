//
//  ViewController.swift
//  Bookorm
//
//  Created by Student Account  on 3/10/23.
//

import UIKit
import LocalAuthentication
import CoreData
// Declare MainViewController class that inherits from UIViewController
class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    // Properties
    static var shouldAuthenticate = true
    var isAuthenticated = false
    // Reload book collection view when the view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookCollectionView.reloadData()
    }
    // Authenticate user when the view did appear/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bookCollectionView.reloadData()
        if MainViewController.shouldAuthenticate {
            authenticateUserWithFaceID()
            MainViewController.shouldAuthenticate = false
        }
    }
    // Selector for entering foreground/
    @objc func willEnterForeground() {
        MainViewController.shouldAuthenticate = true
    }
    // Function to show blur effect
    func showBlurEffect() {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 1001
        view.addSubview(blurEffectView)
    }
    // Function to remove blur effect
    func removeBlurEffect() {
        if let blurEffectView = view.viewWithTag(1001) {
            blurEffectView.removeFromSuperview()
        }
    }

    // Function to authenticate user with Face ID
    func authenticateUserWithFaceID() {
        showBlurEffect()
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to access your app"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        // Authentication was successful
                        self?.handleSuccessfulAuthentication()
                    } else {
                        // Authentication failed, handle the error
                        self?.handleFailedAuthentication(error: error)
                    }
                }
            }
        } else {
            // Device does not support authentication, handle this case
            handleUnsupportedAuthentication()
        }
    }

    // Function to handle successful authentication
    func handleSuccessfulAuthentication() {
        isAuthenticated = true
        removeBlurEffect()
    }

    // Function to handle failed authentication
    func handleFailedAuthentication(error: Error?) {
        // Show an error message
        let alertController = UIAlertController(title: "Authentication Failed", message: "Face ID authentication failed. Please try again.", preferredStyle: .alert)
        
        // Add a "Retry" action to the alert
        alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            // Retry the Face ID authentication process
            self.removeBlurEffect() // Add this line
            self.authenticateUserWithFaceID()
        }))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }


    // Function to handle unsupported authentication
    func handleUnsupportedAuthentication() {
        let alertController = UIAlertController(title: "Unsupported", message: "Your device does not support Face ID.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Outlet for book collection view
    @IBOutlet weak var bookCollectionView: UICollectionView!
    // Properties for books and bookLists
    var books: [Book] = []
    var bookLists: [BookList] = []
    // Function to set up the view when it loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
       
        //loadData()
        //clearStorage()
    }
    // Function to clear book storage
    func clearStorage() {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        books.forEach { item in
            managedContext.delete(item)
        }
        do { try managedContext.save() } catch {}
    }
    // Function to load data
    func loadData() {
        let defaults = UserDefaults.standard
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // Load data from the persistent storage if it exists
        if defaults.bool(forKey: "isLoaded") {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
            do {
                let dbBookItems = try managedContext.fetch(fetchRequest) as! [Book]
                books.append(contentsOf: dbBookItems)
            } catch {}
        }
        else {
            // Add initial data to the persistent storage
            do {
                let b1 = Book(context: managedContext)
                b1.title = "Where the Red Fern Grows"
                b1.summary = "The heartwarming and adventurous tale for all ages about a young boy and his quest for his own red-bone hound hunting dogs."
                b1.author = "Wilson Rawls"
                b1.rating = 4
                books.append(b1)
                let b2 = Book(context: managedContext)
                b2.title = "The Stranger"
                b2.summary = "A story following Meursault, an indifferent settler in French Algeria, who, weeks after his mother's funeral, kills an unnamed Arab man in Algiers."
                b2.author = "Albert Camus"
                b2.rating = 3
                books.append(b2)
                try managedContext.save()
                
                defaults.set(true, forKey: "isLoaded")
            } catch{}
        }
    }
    // Function called when the view is about to be loaded
    override func awakeFromNib() {
        super.awakeFromNib()
        loadData()
    }
    // Collection view delegate and data source methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCollectionCell
        let book = books[indexPath.row]
        cell.bookLabel.text = book.title
        cell.rating = book.rating
        updateRating(bookCell: cell, rating: Int(cell.rating))
        
        return cell
    }
    // Function to update the rating display for a book cell
    func updateRating(bookCell: BookCollectionCell, rating: Int) {
        // Update the visibility of stars based on the rating
        if (rating == 0) {
            bookCell.star1.isHidden = true
            bookCell.star2.isHidden = true
            bookCell.star3.isHidden = true
            bookCell.star4.isHidden = true
            bookCell.star5.isHidden = true
        }else if (rating == 1) {
            bookCell.star1.isHidden = false
            bookCell.star2.isHidden = true
            bookCell.star3.isHidden = true
            bookCell.star4.isHidden = true
            bookCell.star5.isHidden = true
        } else if (rating == 2) {
            bookCell.star1.isHidden = false
            bookCell.star2.isHidden = false
            bookCell.star3.isHidden = true
            bookCell.star4.isHidden = true
            bookCell.star5.isHidden = true
        } else if (rating == 3) {
            bookCell.star1.isHidden = false
            bookCell.star2.isHidden = false
            bookCell.star3.isHidden = false
            bookCell.star4.isHidden = true
            bookCell.star5.isHidden = true
        } else if (rating == 4) {
            bookCell.star1.isHidden = false
            bookCell.star2.isHidden = false
            bookCell.star3.isHidden = false
            bookCell.star4.isHidden = false
            bookCell.star5.isHidden = true
        } else if (rating == 5) {
            bookCell.star1.isHidden = false
            bookCell.star2.isHidden = false
            bookCell.star3.isHidden = false
            bookCell.star4.isHidden = false
            bookCell.star5.isHidden = false
        } else {
            bookCell.star1.isHidden = true
            bookCell.star2.isHidden = true
            bookCell.star3.isHidden = true
            bookCell.star4.isHidden = true
            bookCell.star5.isHidden = true
        }
    }
    // Property to store the selected book
    var selectedBook: Book = Book()
    // Function to handle item selection in the collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedBook = books[indexPath.item]
        performSegue(withIdentifier: "homeToDetail", sender: self)
    }
    // Function to prepare for segue transitions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue is going to the detail view, pass the selected book to the detail view controller
        if segue.identifier == "homeToDetail" {
            let controller = segue.destination as! DetailViewController
            controller.book = selectedBook
        }
    }
}

