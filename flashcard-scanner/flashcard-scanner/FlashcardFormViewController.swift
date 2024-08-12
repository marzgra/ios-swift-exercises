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
    var capturedImage: UIImage?

    var flashcard = Flashcard(mainPhrase: "", example: "", flashcardNumber: "", mainPhraseTranslation: "", exampleTranslation: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupForm()
    }

    func setupForm() {
        let imageView = UIImageView(image: capturedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 200)
        view.addSubview(imageView)

        let mainPhraseLabel = createLabel(text: "Main Phrase:")
        let mainPhraseField = createTextField(placeholder: "Select Main Phrase")
        mainPhraseField.tag = 0

        let exampleLabel = createLabel(text: "Example:")
        let exampleField = createTextField(placeholder: "Select Example")
        exampleField.tag = 1

        let flashcardNumberLabel = createLabel(text: "Flashcard Number:")
        let flashcardNumberField = createTextField(placeholder: "Select Flashcard Number")
        flashcardNumberField.tag = 2

        let mainPhraseTranslationLabel = createLabel(text: "Main Phrase Translation:")
        let mainPhraseTranslationField = createTextField(placeholder: "Select Main Phrase Translation")
        mainPhraseTranslationField.tag = 3

        let exampleTranslationLabel = createLabel(text: "Example Translation:")
        let exampleTranslationField = createTextField(placeholder: "Select Example Translation")
        exampleTranslationField.tag = 4

        let fields = [mainPhraseField, exampleField, flashcardNumberField, mainPhraseTranslationField, exampleTranslationField]

        let stackView = UIStackView(arrangedSubviews: [
            mainPhraseLabel, mainPhraseField,
            exampleLabel, exampleField,
            flashcardNumberLabel, flashcardNumberField,
            mainPhraseTranslationLabel, mainPhraseTranslationField,
            exampleTranslationLabel, exampleTranslationField
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.frame = CGRect(x: 20, y: 320, width: view.frame.width - 40, height: 300)
        view.addSubview(stackView)

        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveFlashcard), for: .touchUpInside)
        saveButton.frame = CGRect(x: (view.frame.width - 120) / 2, y: stackView.frame.maxY + 20, width: 120, height: 50)
        view.addSubview(saveButton)

        // Set up tap recognizer for selecting scanned text
        for field in fields {
            field.addTarget(self, action: #selector(selectScannedText(_:)), for: .editingDidBegin)
        }
    }

    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }

    func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }

    @objc func selectScannedText(_ textField: UITextField) {
        let alertController = UIAlertController(title: "Select Text", message: nil, preferredStyle: .actionSheet)

        for text in scannedText {
            let action = UIAlertAction(title: text, style: .default) { [weak self] _ in
                textField.text = text
                self?.updateFlashcard(field: textField.tag, with: text)
            }
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
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
}
