//
//  RecordVideoViewModel.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 04.02.2023.
//

import Foundation
import Combine
import AVFoundation
import Photos

class RecordVideoViewModel: ObservableObject {
    
    @Published var isSaved = false
    
    let cameraService = CameraService()
    
    init() {
        cameraService.checkPermission()
    }
    
    //MARK: - Save video
    func saveVideoToLibrary(videoURL: URL) {
     PHPhotoLibrary.shared().performChanges({
         PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL) }) { [weak self] saved, error in
             guard let self = self else { return }
         if let error = error {
             print("Error saving video to library: \(error.localizedDescription)")
         }
         if saved {
             print("Video save to library")
             self.isSaved = true
             self.cameraService.session?.stopRunning()
         }
     }
 }
    
    //MARK: - Crop the video
    /// This part using  (https://stackoverflow.com/questions/35696188/how-to-trim-a-video-in-swift-for-a-particular-time)
    /// answered Mar 1, 2016 at 6:33 Parv Bhasker
    func cropVideo(sourceURL1: URL, statTime: Float, endTime: Float) {
       let manager = FileManager.default

       guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
       let mediaType = "mp4"
       if mediaType == "mp4" as String {
           let asset = AVAsset(url: sourceURL1 as URL)
           let length = Float(asset.duration.value) / Float(asset.duration.timescale)
           print("video length: \(length) seconds")

           let start = statTime
           let end = endTime

           var outputURL = documentDirectory.appendingPathComponent("output")
           do {
               try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
               outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).\(mediaType)")
           }catch let error {
               print(error)
           }

           //Remove existing file
           _ = try? manager.removeItem(at: outputURL)


           guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
           exportSession.outputURL = outputURL
           exportSession.outputFileType = .mp4

           let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
           let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
           let timeRange = CMTimeRange(start: startTime, end: endTime)

           exportSession.timeRange = timeRange
           exportSession.exportAsynchronously{
               switch exportSession.status {
               case .completed:
                   print("exported at \(outputURL)")
                   self.saveVideoToLibrary(videoURL: outputURL)
               case .failed:
                   print("failed \(String(describing: exportSession.error))")

               case .cancelled:
                   print("cancelled \(String(describing: exportSession.error))")

               default: break
               }
           }
       }
   }
}
