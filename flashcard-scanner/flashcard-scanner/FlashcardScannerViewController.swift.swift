import SwiftUI
import AVFoundation
import Vision

// Model to hold flashcard data
struct Flashcard {
    var language1: String
    var mainText: String
    var cardNumber: String
    var language2: String
}

// SwiftUI View with Camera View
struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = FlashcardScannerViewController

    func makeUIViewController(context: Context) -> FlashcardScannerViewController {
        return FlashcardScannerViewController()
    }

    func updateUIViewController(_ uiViewController: FlashcardScannerViewController, context: Context) {}
}

// The main view controller for capturing and processing flashcards
class FlashcardScannerViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var flashcard = Flashcard(language1: "", mainText: "", cardNumber: "", language2: "")
    
    var scanningBackSide = false

    let language1Label = UILabel()
    let mainTextLabel = UILabel()
    let cardNumberLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    func setupUI() {
        language1Label.frame = CGRect(x: 20, y: 50, width: view.frame.width - 40, height: 50)
        mainTextLabel.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 200)
        cardNumberLabel.frame = CGRect(x: 20, y: view.frame.height - 100, width: view.frame.width - 40, height: 50)
        
        language1Label.textColor = .white
        mainTextLabel.textColor = .white
        cardNumberLabel.textColor = .white
        
        view.addSubview(language1Label)
        view.addSubview(mainTextLabel)
        view.addSubview(cardNumberLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    func handleScanComplete() {
        let alert = UIAlertController(title: "Flip Flashcard", message: "Flip the flashcard and tap OK to scan the back side.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.scanningBackSide = true
        }))
        present(alert, animated: true, completion: nil)
    }
}

// String extensions for custom functionality
extension String {
    var isNumeric: Bool {
        return !isEmpty && allSatisfy { $0.isNumber }
    }
    
    var isUppercase: Bool {
        return self == self.uppercased() && rangeOfCharacter(from: .letters) != nil
    }
}

// Vision framework for text recognition
extension FlashcardScannerViewController {
    func detectText(in image: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                let recognizedText = topCandidate.string
                
                if self.scanningBackSide {
                    self.flashcard.language2 = recognizedText
                    DispatchQueue.main.async {
                        self.mainTextLabel.text = "Translation: \(recognizedText)"
                    }
                } else {
                    if recognizedText.isNumeric {
                        self.flashcard.cardNumber = recognizedText
                        DispatchQueue.main.async {
                            self.cardNumberLabel.text = "Number: \(recognizedText)"
                        }
                    } else if recognizedText.isUppercase {
                        self.flashcard.language1 = recognizedText
                        DispatchQueue.main.async {
                            self.language1Label.text = "Language 1: \(recognizedText)"
                        }
                    } else {
                        self.flashcard.mainText = recognizedText
                        DispatchQueue.main.async {
                            self.mainTextLabel.text = "Main Text: \(recognizedText)"
                        }
                    }
                }
            }
            
            print("Flashcard data: \(self.flashcard)")
            if !self.scanningBackSide {
                self.handleScanComplete()
            }
        }
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? requestHandler.perform([request])
    }
}

// Capture video frames and process with Vision
extension FlashcardScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        detectText(in: pixelBuffer)
    }
}

// Main SwiftUI App Entry
@main
struct FlashcardScannerApp: App {
    var body: some Scene {
        WindowGroup {
            CameraView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
