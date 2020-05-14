//
//  BookTableViewCell.swift
//  Book List App
//
//  Created by Iordan, Raluca on 11/05/2020.
//  Copyright © 2020 Iordan, Raluca. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var bookCover: CustomImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(for book: Book) {
        
        bookCover.image = thumbnail(for: book)
    }
    
    func thumbnail(for book: Book) -> UIImage {
        if let image = book.photoImage {
            return image.resizedImage(withBounds: CGSize(width: 52, height: 52))
        }
        return UIImage(named: "No Photo")!
    }
    
}
