//
//  EnterEventNameViewController.swift
//  GatherTeam
//
//  Created by Nikita on 24.12.2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class EnterEventNameViewController: UIViewController, UITextViewDelegate {
    
    var viewModel: EnterEventNameViewModelType!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    private let textViewPlaceholderText = "E.g., I am football games organizer, you should bring with you ball, water and all other equipment."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.layer.cornerRadius = 16
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
        nameTextField.backgroundColor = .systemGray6
        
        nameTextField.setLeftPaddingPoints(20)
        nameTextField.setRightPaddingPoints(20)
        setupPlaceholder(for: nameTextField, placeholder: "E.g., Football match ")
        
        eventDescriptionTextView.layer.cornerRadius = 16
        eventDescriptionTextView.layer.borderWidth = 1
        eventDescriptionTextView.layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
        eventDescriptionTextView.backgroundColor = .systemGray6
        
        eventDescriptionTextView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
        eventDescriptionTextView.delegate = self
        
        eventDescriptionTextView.text = textViewPlaceholderText
        eventDescriptionTextView.textColor = UIColor.gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        guard
            let name = nameTextField.text,
            !name.isEmpty,
            eventDescriptionTextView.text != textViewPlaceholderText
        else {
            let alert = UIAlertController(title: "You could not do this action", message: "You need to enter name and description.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        viewModel.goToSelectEnentType(nameTextField.text ?? "", eventDescriptionTextView.text)
    }
    
    func setupPlaceholder(for textField: UITextField, placeholder: String) {
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)
        ])
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholderText
            textView.textColor = UIColor.gray
        }
    }
}
