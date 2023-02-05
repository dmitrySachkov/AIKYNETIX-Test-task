//
//  CameraService.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 03.02.2023.
//

import Foundation
import AVFoundation

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

class CameraService: NSObject {
    
    var device: AVCaptureDevice?
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCaptureMovieFileOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    var videoRecordCompletionBlock: ((URL?, Error?) -> Void)?
    
    //MARK: - Check User permission to camera access
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self, granted else { return }
                
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            }
        case .restricted:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }
    
    //MARK: - Setup camera
    private func setupCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                self.device = device
                DispatchQueue.global().async {
                    session.startRunning()
                }
                self.session = session
                
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Record Video
    func recordVideo(completion: @escaping (URL?, Error?) -> Void) {
        guard let captureSession = self.session, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent("output.mov")
        try? FileManager.default.removeItem(at: fileUrl)
        output.startRecording(to: fileUrl, recordingDelegate: self)
        self.videoRecordCompletionBlock = completion
    }
    
    func stopRecording(completion: @escaping (Error?)->Void) {
        guard let captureSession = self.session, captureSession.isRunning else {
            completion(CameraControllerError.captureSessionIsMissing)
            return
        }
        self.output.stopRecording()
    }
}



//MARK: - Implement AVCaptureFileOutputRecordingDelegate
extension CameraService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            self.videoRecordCompletionBlock?(outputFileURL, nil)
        } else {
            self.videoRecordCompletionBlock?(nil, error)
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
