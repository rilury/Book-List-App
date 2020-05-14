//
//  BookListVC.swift
//  Book List App
//
//  Created by Iordan, Raluca on 11/05/2020.
//  Copyright © 2020 Iordan, Raluca. All rights reserved.
//

import UIKit
import CoreData

class BookListVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Variables
    
    var managedObjectContext: NSManagedObjectContext = AppDelegate.persistentContainer.viewContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<Book> = {
        let fetchRequest = NSFetchRequest<Book>()
        
        let entity = Book.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "author", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Books")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch()
        setupViews()
        
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    //MARK: - Helpers
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func setupViews() {
        tableView.isHidden = fetchedResultsController.fetchedObjects?.count ?? 0 == 0
        emptyView.isHidden = fetchedResultsController.fetchedObjects?.count ?? 0 != 0
    }
    
}

    //MARK: - TableView Data Source

extension BookListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookListCell", for: indexPath) as! BookTableViewCell
        
        let book = fetchedResultsController.object(at: indexPath)
        cell.configure(for: book)
        cell.authorName.text = book.author
        cell.titleLabel.text = book.title
        
        return cell
    }
    
}

    //MARK: - TableView Delegate

extension BookListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let bookDetailsVC = storyboard.instantiateViewController(withIdentifier: "bookDetails") as? BookDetailsVC {
            bookDetailsVC.myBook = fetchedResultsController.object(at: indexPath)
            self.navigationController?.pushViewController(bookDetailsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete), let books = fetchedResultsController.fetchedObjects {
            
            
            if  let coreDataIndexPath = fetchedResultsController.indexPath(forObject: books[indexPath.row]) {
                let bookToBeDeleted = fetchedResultsController.object(at: coreDataIndexPath)
                bookToBeDeleted.removePhotoFile()
                managedObjectContext.delete(bookToBeDeleted)
                
                do {
                    try managedObjectContext.save()
                    setupViews()
                } catch {
                    fatalCoreDataError(error)
                }
            }
            
            
            
            
        }
    }
}


    //MARK: - Fetched Results Controller Delegate

extension BookListVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? BookTableViewCell {
                let book = controller.object(at: indexPath!) as! Book
                cell.configure(for: book)
            }
            
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            break
            // fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
