//
//  BookDetailsVC.swift
//  Book List App
//
//  Created by Iordan, Raluca on 11/05/2020.
//  Copyright © 2020 Iordan, Raluca. All rights reserved.
//

import UIKit

class BookDetailsVC: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookNotesLabel: UILabel!
    @IBOutlet weak var bookCover: CustomImageView!
    
    //MARK: - Variables
    var myBook = Book()
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTitleLabel.text = myBook.title
        authorLabel.text = myBook.author
        bookNotesLabel.text = myBook.notes
        bookCover.image = thumbnail(for: myBook)
    }
    
    //MARK: - Helpers
     
     func thumbnail(for book: Book) -> UIImage {
         if let image = book.photoImage {
             return image.resizedImage(withBounds: CGSize(width: 52, height: 52))
         }
         return UIImage(named: "No Photo")!
     }

}
