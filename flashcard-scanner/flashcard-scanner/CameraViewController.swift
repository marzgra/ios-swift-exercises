import SwiftUI
import AVFoundation
import Vision

// SwiftUI View with Camera View
struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController

    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var photoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var isCapturingFrontSide = true // Track if capturing front side or back side
    var frontSideRecognizedStrings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            try videoCaptureDevice.lockForConfiguration()
            videoCaptureDevice.focusMode = .continuousAutoFocus
            videoCaptureDevice.unlockForConfiguration()
        } catch {
            return
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusTapped))
        view.addGestureRecognizer(tapGesture)

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        }

        if (captureSession.canAddOutput(photoOutput)) {
            captureSession.addOutput(photoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 10
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        captureButton.frame = CGRect(x: (view.frame.width - 120) / 2, y: view.frame.height - 80, width: 120, height: 50)
        view.addSubview(captureButton)
    }


    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func focusTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to focus")
        }
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        
        // Process the captured image for text detection
        processImage(uiImage)
    }

    func promptToFlipCard() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Flip the Flashcard", message: "Please flip the flashcard and capture the other side.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.isCapturingFrontSide = false
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            var recognizedStrings: [String] = []
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedStrings.append(topCandidate.string)
            }

            DispatchQueue.main.async {
                if self?.isCapturingFrontSide == true {
                    self?.frontSideRecognizedStrings = recognizedStrings
                    self?.promptToFlipCard()
                } else {
                    let formVC = FlashcardFormViewController()
                    formVC.scannedText = recognizedStrings
                    formVC.frontSideText = self?.frontSideRecognizedStrings ?? []
                    self?.navigationController?.pushViewController(formVC, animated: true)
                }
            }
        }

        try? requestHandler.perform([request])
    }
}
