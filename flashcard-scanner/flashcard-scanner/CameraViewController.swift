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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    func setupCamera() {
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
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        
        // Process the captured image for text detection
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
                // Navigate to the next view with recognized text
                let formVC = FlashcardFormViewController()
                formVC.scannedText = recognizedStrings
                formVC.capturedImage = image
                self?.navigationController?.pushViewController(formVC, animated: true)
            }
        }

        try? requestHandler.perform([request])
    }
}
