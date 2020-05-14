//
//  CreateBookVC.swift
//  Book List App
//
//  Created by Iordan, Raluca on 11/05/2020.
//  Copyright © 2020 Iordan, Raluca. All rights reserved.
//

import UIKit
import CoreData

class CreateBookVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var bookTitle: UITextField!
    @IBOutlet weak var bookNotes: UITextView!
    @IBOutlet weak var authorName: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var bookCover: UIImageView!
    @IBOutlet weak var choosePhotoLabel: UILabel!
    @IBOutlet weak var bookCoverTopConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    
    var managedObjectContext: NSManagedObjectContext = AppDelegate.persistentContainer.viewContext
    var selectedImage: UIImage?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTapGestureToDismissKeyboard()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImage))
        bookCover.addGestureRecognizer(tapGesture)
        bookCover.isUserInteractionEnabled = true
        
        setupDelegates()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    //MARK: - Helpers
    func setupDelegates() {
        bookTitle.delegate = self
        bookNotes.delegate = self
        authorName.delegate =  self
    }
    
    @objc func handleSelectProfileImage() {
        choosePhoto()
    }
    
    func saveBook() {
        if let title = self.bookTitle.text, !title.isEmpty, let notes = self.bookNotes.text, !notes.isEmpty, let author = self.authorName.text, !author.isEmpty {
            
            self.saveBookToCoreData(id:  NSUUID().uuidString)
            
        }
    }
    
    func saveBookToCoreData (id: String) {
        let book = Book(context: managedObjectContext)
        if let title = self.bookTitle.text, !title.isEmpty, let notes = self.bookNotes.text, !notes.isEmpty, let author = self.authorName.text, !author.isEmpty {
            book.title = title
            book.author = author
            book.notes = notes
        }
        
        if let image = selectedImage {
            book.coverPhotoID = Book.nextPhotoID() as NSNumber
            
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: book.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
            let count = self.navigationController?.viewControllers.count ?? 1
            (self.navigationController?.viewControllers[count - 2] as? BookListVC)?.setupViews()
            self.navigationController?.popViewController(animated: true)
            
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval  else { return }
        
        let offset = keyboardFrame.size.height - view.safeAreaInsets.bottom
        
        bookCoverTopConstraint.constant = -offset + 100
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: offset, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval  else { return }
        
        bookCoverTopConstraint.constant = 30
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    
    //MARK: - Gestures
    func createTapGestureToDismissKeyboard() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardWhenTapOnTheView))
        tapGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboardWhenTapOnTheView() {
        bookNotes.resignFirstResponder()
        bookTitle.resignFirstResponder()
        authorName.resignFirstResponder()
    }
    
    //MARK: - Actions
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: "Cancel these notes? You will not be able to undo this action.", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func saveBook(_ sender: UIButton) {
        
        if self.selectedImage == nil {
            let alert = UIAlertController(title: "Book cover not selected", message: "Please choose a book cover!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            saveBook()
            
        }
    }
    
}

    //MARK:  - Text Delegates

extension CreateBookVC: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

    //MARK: - ImagePicker

extension CreateBookVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    func choosePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            takePhotoWithCamera()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("did finish picking photo")
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            bookCover.image = image
            choosePhotoLabel.isHidden  = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}
