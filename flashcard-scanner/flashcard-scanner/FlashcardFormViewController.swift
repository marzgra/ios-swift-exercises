import SwiftUI
import UIKit

struct Flashcard {
    var mainPhrase: String
    var example: String
    var flashcardNumber: String
    var mainPhraseTranslation: String
    var exampleTranslation: String
    
    init(mainPhrase: String, example: String, flashcardNumber: String, mainPhraseTranslation: String, exampleTranslation: String) {
        self.mainPhrase = mainPhrase
        self.example = example
        self.flashcardNumber = flashcardNumber
        self.mainPhraseTranslation = mainPhraseTranslation
        self.exampleTranslation = exampleTranslation
    }
    
    init() {
        self.init(mainPhrase: "", example: "", flashcardNumber: "", mainPhraseTranslation: "", exampleTranslation: "")
    }
    
}

class FlashcardFormViewController: UIViewController, UITextFieldDelegate {
    var scannedText: [String] = []
    var frontSideText: [String] = [] // Text recognized from the front side of the card
    
    var flashcard = Flashcard(mainPhrase: "", example: "", flashcardNumber: "", mainPhraseTranslation: "", exampleTranslation: "")
    
    let scrollView = UIScrollView()
    
    // Define labels for displaying recognized text
    let mainPhraseSelection = UILabel()
    let exampleSelection = UILabel()
    let flashcardNumberSelection = UILabel()
    let mainPhraseTranslationSelection = UILabel()
    let exampleTranslationSelection = UILabel()
    
    // label
    let mainPhraseLabel = UILabel()
    let exampleLabel = UILabel()
    let flashcardNumberLabel = UILabel()
    let mainPhraseTranslationLabel = UILabel()
    let exampleTranslationLabel = UILabel()
    
    // Define text fields for editing
    let mainPhraseEditableField = UITextField()
    let exampleEditableField = UITextField()
    let flashcardNumberEditableField = UITextField()
    let mainPhraseTranslationEditableField = UITextField()
    let exampleTranslationEditableField = UITextField()
    
    var isEditingText = false // Track whether the form is in edit mode
    
    var selectionText =  "Select text..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupKeyboardNotifications()
        setupForm()
        
        mainPhraseEditableField.delegate = self
        exampleEditableField.delegate = self
        flashcardNumberEditableField.delegate = self
        mainPhraseTranslationEditableField.delegate = self
        exampleTranslationEditableField.delegate = self
    }
    
    // This method is called when the user ends editing in the text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Update the label with the text from the text field
//        label.text = textField.text
    }
    
    // Optional: To hide the keyboard when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupForm() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        let mainPhraseLabelText = "Main Phrase:"
        let exampleLabelText = "Example:"
        let flashcardNumberLabelText = "Flashcard Number:"
        let mainPhraseTranslationLabelText = "Main Phrase Translation:"
        let exampleTranslationLabelText = "Example Translation:"
        
        
        // Create labels
        setupLabel(mainPhraseLabel, text: mainPhraseLabelText)
        setupLabel(exampleLabel, text: exampleLabelText)
        setupLabel(flashcardNumberLabel, text: flashcardNumberLabelText)
        setupLabel(mainPhraseTranslationLabel, text: mainPhraseTranslationLabelText)
        setupLabel(exampleTranslationLabel, text: exampleTranslationLabelText)
        
        
        // Create labels to select text
        setupSelectionLabel(mainPhraseSelection, tag: 0)
        setupSelectionLabel(exampleSelection, tag: 1)
        setupSelectionLabel(flashcardNumberSelection, tag: 2)
        setupSelectionLabel(mainPhraseTranslationSelection, tag: 3)
        setupSelectionLabel(exampleTranslationSelection, tag: 4)
        
        // Initialize text fields for edit mode
        configureTextField(mainPhraseEditableField, tag: 0)
        configureTextField(exampleEditableField, tag: 1)
        configureTextField(flashcardNumberEditableField, tag: 2)
        configureTextField(mainPhraseTranslationEditableField, tag: 3)
        configureTextField(exampleTranslationEditableField, tag: 4)
        
        
        // Create a stack view to hold the labels and text fields
        let stackView = UIStackView(arrangedSubviews: [
            setupSelectingTextWithLabel(mainPhraseSelection, textLabel: mainPhraseLabel), setupEditingTextWithLabel(mainPhraseEditableField, textLabel: mainPhraseLabel),
            setupSelectingTextWithLabel(exampleSelection, textLabel: exampleLabel ), setupEditingTextWithLabel(exampleEditableField, textLabel: exampleLabel ),
            setupSelectingTextWithLabel(flashcardNumberSelection, textLabel: flashcardNumberLabel), setupEditingTextWithLabel(flashcardNumberEditableField, textLabel: flashcardNumberLabel),
            setupSelectingTextWithLabel(mainPhraseTranslationSelection, textLabel: mainPhraseTranslationLabel), setupEditingTextWithLabel(mainPhraseTranslationEditableField, textLabel: mainPhraseTranslationLabel),
            setupSelectingTextWithLabel(exampleTranslationSelection, textLabel: exampleTranslationLabel), setupEditingTextWithLabel(exampleTranslationEditableField, textLabel: exampleTranslationLabel)
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually // Ensure equal distribution of space
        stackView.frame = CGRect(x: 20, y: 20, width: view.frame.width - 40, height: 400)
        scrollView.addSubview(stackView)
        
        // Set scroll view content size to accommodate the form and save button
        scrollView.contentSize = CGSize(width: view.frame.width, height: stackView.frame.maxY + 80)
        
        // Add the "Edit" button to toggle between view and edit modes
        let editButton = UIButton(type: .system)
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(toggleEditMode), for: .touchUpInside)
        editButton.frame = CGRect(x: 20, y: scrollView.contentSize.height + 10, width: view.frame.width - 40, height: 40)
        scrollView.addSubview(editButton)
        
        // Add the save button
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveFlashcard), for: .touchUpInside)
        saveButton.frame = CGRect(x: 20, y: scrollView.contentSize.height - 60, width: view.frame.width - 40, height: 50)
        scrollView.addSubview(saveButton)
    }
    
    func setupEditingTextWithLabel(_ textField: UITextField, textLabel: UILabel) -> UIView {
        let stackView = UIStackView(arrangedSubviews: [textLabel, textField])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.frame = CGRect(x: 20, y: 20, width: view.frame.width - 40, height: 400)
        
        scrollView.addSubview(stackView)
        return stackView
    }
    
    func setupSelectingTextWithLabel(_ textField: UILabel, textLabel: UILabel) -> UIView {
        let stackView = UIStackView(arrangedSubviews: [textField, textLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.frame = CGRect(x: 20, y: 20, width: view.frame.width - 40, height: 400)
        
        scrollView.addSubview(stackView)
        return stackView
    }
    
    func setupLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
    }
    
    func setupSelectionLabel(_ label: UILabel, tag: Int) {
        label.text = selectionText
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.tag = tag
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectScannedText(_:)))
        label.addGestureRecognizer(tapGesture)
    }
    
    func setupEditTextLabel(_ label: UILabel, text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
    }
    
    func configureTextField(_ textField: UITextField, tag: Int) {
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.tag = tag
        textField.isHidden = true // Hide text fields initially
        textField.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editScannedText(_:)))
        textField.addGestureRecognizer(tapGesture)
    }
    
    @objc func toggleEditMode() {
        isEditingText.toggle()
        
        // Toggle between labels and text fields
        mainPhraseSelection.isHidden = isEditingText
        exampleSelection.isHidden = isEditingText
        flashcardNumberSelection.isHidden = isEditingText
        mainPhraseTranslationSelection.isHidden = isEditingText
        exampleTranslationSelection.isHidden = isEditingText
        
        mainPhraseEditableField.isHidden = !isEditingText
        exampleEditableField.isHidden = !isEditingText
        flashcardNumberEditableField.isHidden = !isEditingText
        mainPhraseTranslationEditableField.isHidden = !isEditingText
        exampleTranslationEditableField.isHidden = !isEditingText
        
        if isEditingText {
            // Populate text fields with current label values
            mainPhraseEditableField.text = flashcard.mainPhrase
            exampleEditableField.text = flashcard.example
            flashcardNumberEditableField.text = flashcard.flashcardNumber
            mainPhraseTranslationEditableField.text = flashcard.mainPhraseTranslation
            exampleTranslationEditableField.text = flashcard.exampleTranslation
        }
        
        if !isEditingText {
            // Populate text fields with current label values
            mainPhraseSelection.text = flashcard.mainPhrase
            exampleSelection.text = flashcard.example
            flashcardNumberSelection.text = flashcard.flashcardNumber
            mainPhraseTranslationSelection.text = flashcard.mainPhraseTranslation
            exampleTranslationSelection.text = flashcard.exampleTranslation
        }
    }
    
    @objc func selectScannedText(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        let alertController = UIAlertController(title: "Select Text", message: nil, preferredStyle: .actionSheet)
        
        let textOptions = frontSideText + scannedText
        
        for text in textOptions {
            let action = UIAlertAction(title: text, style: .default) { [weak self] _ in
                let existingTxt = label.text
                if existingTxt == self?.selectionText {
                    label.text = ""
                }
                if let existingText = label.text, !existingText.isEmpty {
                    label.text = existingText + "\n" + text
                } else {
                    label.text = text
                }
                self?.updateFlashcard(field: label.tag, with: label.text ?? "")
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func editScannedText(_ gesture: UITapGestureRecognizer) {
        guard let textField = gesture.view as? UITextField else { return }
        self.updateFlashcard(field: textField.tag, with: textField.text ?? "")
    }
    
    func updateFlashcard(field tag: Int, with text: String) {
        switch tag {
        case 0:
            flashcard.mainPhrase = text
        case 1:
            flashcard.example = text
        case 2:
            flashcard.flashcardNumber = text
        case 3:
            flashcard.mainPhraseTranslation = text
        case 4:
            flashcard.exampleTranslation = text
        default:
            break
        }
    }
    
    @objc func saveFlashcard() {
        // Here you can save or further process the flashcard
        print("Saved flashcard: \(flashcard)")
        
        let csvString = flashcard.mainPhrase + "," + flashcard.mainPhraseTranslation
        
        do {
            let path = try FileManager.default.url(for: .documentDirectory,
                                                   in: .allDomainsMask,
                                                   appropriateFor: nil,
                                                   create: false)
            
            let fileURL = path.appendingPathComponent("TrailTime.csv")
            try csvString.write(to: fileURL, atomically: true , encoding: .utf8)
        } catch {
            print("error creating file")
        }
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
