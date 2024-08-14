import SwiftUI
import UIKit

struct Flashcard {
    var mainPhrase: String
    var example: String
    var flashcardNumber: String
    var mainPhraseTranslation: String
    var exampleTranslation: String
}

class FlashcardFormViewController: UIViewController {
    var scannedText: [String] = []
    var frontSideText: [String] = [] // Text recognized from the front side of the card

    var flashcard = Flashcard(mainPhrase: "", example: "", flashcardNumber: "", mainPhraseTranslation: "", exampleTranslation: "")

    let scrollView = UIScrollView()

    // Define labels for displaying recognized text
    let mainPhraseLabel = UILabel()
    let exampleLabel = UILabel()
    let flashcardNumberLabel = UILabel()
    let mainPhraseTranslationLabel = UILabel()
    let exampleTranslationLabel = UILabel()

    // Define text fields for editing
    let mainPhraseField = UITextField()
    let exampleField = UITextField()
    let flashcardNumberField = UITextField()
    let mainPhraseTranslationField = UITextField()
    let exampleTranslationField = UITextField()

    var isEditingText = false // Track whether the form is in edit mode

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupKeyboardNotifications()
        setupForm()
    }

    func setupForm() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)

        setupLabel(mainPhraseLabel, text: "Main Phrase:", tag: 0)
        setupLabel(exampleLabel, text: "Example:", tag: 1)
        setupLabel(flashcardNumberLabel, text: "Flashcard Number:", tag: 2)
        setupLabel(mainPhraseTranslationLabel, text: "Main Phrase Translation:", tag: 3)
        setupLabel(exampleTranslationLabel, text: "Example Translation:", tag: 4)

        // Initialize text fields with placeholders (for edit mode)
        configureTextField(mainPhraseField, tag: 0)
        configureTextField(exampleField, tag: 1)
        configureTextField(flashcardNumberField, tag: 2)
        configureTextField(mainPhraseTranslationField, tag: 3)
        configureTextField(exampleTranslationField, tag: 4)


        // Create the stack view
        let stackView = UIStackView(arrangedSubviews: [
                    mainPhraseLabel, mainPhraseField,
                    exampleLabel, exampleField,
                    flashcardNumberLabel, flashcardNumberField,
                    mainPhraseTranslationLabel, mainPhraseTranslationField,
                    exampleTranslationLabel, exampleTranslationField
                ])
        stackView.axis = .vertical
        stackView.spacing = 10
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

        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveFlashcard), for: .touchUpInside)
        saveButton.frame = CGRect(x: 20, y: scrollView.contentSize.height - 60, width: view.frame.width - 40, height: 50)
        scrollView.addSubview(saveButton)
    }
    
    @objc func toggleEditMode() {
        isEditingText.toggle()

        // Toggle between labels and text fields
        mainPhraseLabel.isHidden = isEditingText
        exampleLabel.isHidden = isEditingText
        flashcardNumberLabel.isHidden = isEditingText
        mainPhraseTranslationLabel.isHidden = isEditingText
        exampleTranslationLabel.isHidden = isEditingText

        mainPhraseField.isHidden = !isEditingText
        exampleField.isHidden = !isEditingText
        flashcardNumberField.isHidden = !isEditingText
        mainPhraseTranslationField.isHidden = !isEditingText
        exampleTranslationField.isHidden = !isEditingText

        if isEditingText {
            // Populate text fields with current label values
            mainPhraseField.text = mainPhraseLabel.text
            exampleField.text = exampleLabel.text
            flashcardNumberField.text = flashcardNumberLabel.text
            mainPhraseTranslationField.text = mainPhraseTranslationLabel.text
            exampleTranslationField.text = exampleTranslationLabel.text
            
        }
    }

    func setupLabel(_ label: UILabel, text: String, tag: Int) {
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.tag = tag
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectScannedText(_:)))
        label.addGestureRecognizer(tapGesture)
    }

    func configureTextField(_ textField: UITextField, tag: Int) {
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.tag = tag
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editScannedText(_:)))
        textField.isHidden = true // Hide text fields initially
    }

    @objc func selectScannedText(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        let alertController = UIAlertController(title: "Select Text", message: nil, preferredStyle: .actionSheet)

        let textOptions = frontSideText + scannedText

        for text in textOptions {
            let action = UIAlertAction(title: text, style: .default) { [weak self] _ in
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
        guard let label = gesture.view as? UILabel else { return }
        updateFlashcard(field: label.tag, with: label.text ?? "")
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



//struct FlashcardFormViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        FlashcardFormViewController()
//    }
//}
