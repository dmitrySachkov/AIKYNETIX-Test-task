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
import CoreData

enum AppURLS {
  static func documentsDirectory() -> URL {
    guard let docspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
      fatalError("unable to get system docs directory - serious problems")
    }
    return URL(fileURLWithPath: docspath)
  }
}

class RecordVideoViewModel: ObservableObject {
    
    @Published var isSaved = false

    private var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "AIKYNETIX_Test_task")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          })
          return container
      }()
    
    let cameraService = CameraService()
    
    init() {
        cameraService.checkPermission()
    }
    
    //MARK: - Save video
    func saveVideoToLibrary(videoURL: URL) {
        
        guard let folderURL = URL.createFolder(folderName: "StoredVideos") else {
            print("Can't create url")
            return
        }
        let name = "\(UUID().uuidString)" + ".mov"
        let permanentFileURL = folderURL.appendingPathComponent(name)
        do {
            let videoData = try Data(contentsOf: videoURL)
            try videoData.write(to: permanentFileURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        
        let context = persistentContainer.viewContext
        
        let newVideo = NSEntityDescription.insertNewObject(forEntityName: "Video", into: context) as! Video
        newVideo.name = name
        newVideo.date = getDate()
        
        do {
            try context.save()
            print("Video save to data base")
            self.isSaved = true
            self.cameraService.session?.stopRunning()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Crop the video
    /// This part using  (https://stackoverflow.com/questions/35696188/how-to-trim-a-video-in-swift-for-a-particular-time)
    /// answered Mar 1, 2016 at 6:33 Parv Bhasker
    func cropVideo(sourceURL1: URL, statTime: Float, endTime: Float) {
       let manager = FileManager.default

       guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
       let mediaType = "mov"
       if mediaType == "mov" as String {
           let asset = AVAsset(url: sourceURL1 as URL)
           let length = Float(asset.duration.value) / Float(asset.duration.timescale)

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
           exportSession.outputFileType = .mov

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
    
    //MARK: - DateFormatter
    private func getDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let toDayDateString = dateFormatter.string(from: date)
        return toDayDateString
    }
}

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
            return folderURL
        }
        return nil
    }
}
