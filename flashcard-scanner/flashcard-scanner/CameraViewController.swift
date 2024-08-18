import SwiftUI
import AVFoundation
import Vision
struct CameraView: UIViewControllerRepresentable {
    @Binding var frontSideText: [String]
    @Binding var backSideText: [String]
    @Binding var navigateToFormView: Bool

    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        var isCapturingFrontSide = true
        var frontSideRecognizedStrings: [String] = []

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation() else { return }
            guard let uiImage = UIImage(data: imageData) else { return }

            processImage(uiImage)
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
                        self?.parent.frontSideText = self?.frontSideRecognizedStrings ?? []
                        self?.parent.backSideText = recognizedStrings
                        self?.parent.navigateToFormView = true // Trigger navigation
                    }
                }
            }

            try? requestHandler.perform([request])
        }

        func promptToFlipCard() {
            DispatchQueue.main.async {
                guard let windowScene = UIApplication.shared.connectedScenes
                        .first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    return
                }

                let alert = UIAlertController(title: "Flip the Flashcard", message: "Please flip the flashcard and capture the other side.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    self?.isCapturingFrontSide = false
                }))
                
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.coordinator = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    class CameraViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var photoOutput = AVCapturePhotoOutput()
        var previewLayer: AVCaptureVideoPreviewLayer!
        var coordinator: Coordinator?
        
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
            if let coordinator = coordinator {
                photoOutput.capturePhoto(with: settings, delegate: coordinator)
            } else {
                print("Coordinator is nil, cannot capture photo.")
            }
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
}

struct ContentView: View {
    @State private var frontSideText: [String] = []
    @State private var backSideText: [String] = []
    @State private var navigateToFormView = false

    var body: some View {
        NavigationStack {
            VStack {
                CameraView(frontSideText: $frontSideText, backSideText: $backSideText, navigateToFormView: $navigateToFormView)
                    .edgesIgnoringSafeArea(.all)
                    .navigationDestination(isPresented: $navigateToFormView) {
                        FormView(scannedText: backSideText, frontSideText: frontSideText)
                    }
            }
        }
    }
}

