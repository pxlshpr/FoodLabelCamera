import AVKit
import SwiftUI
import FoodLabelScanner
import SwiftHaptics

public typealias FoodLabelScanHandler = (ScanResult, UIImage) -> ()

class FoodLabelCameraViewModel: ObservableObject {
    
    /// Tweak this if needed, but these current values result in the least dropped frames with the quickest response time on the iPhone 13 Pro Max
    let MinimumTimeBetweenScans = 0.5
    let TimeBeforeFirstScan: Double = 0.5
    let MaximumConcurrentScanTasks = 3
    
    let scanResultSets = ScanResultSets()
    @Published var foodLabelBoundingBox: CGRect? = nil
    @Published var barcodeBoundingBoxes: [CGRect] = []
    @Published var didSetBestCandidate = false
    @Published var shouldDismiss = false
    
    var scanTasks: [Task<ScanResult, Error>] = []
    var lastScanTime: CFAbsoluteTime? = nil
    var timeBetweenScans: Double
    
    let foodLabelScanHandler: FoodLabelScanHandler
    
    init(foodLabelScanHandler: @escaping FoodLabelScanHandler) {
        self.foodLabelScanHandler = foodLabelScanHandler
        self.timeBetweenScans = TimeBeforeFirstScan
    }
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        Task {
            if let lastScanTime {
                /// Make sure enough time since the last scan has elapsed, and we're not currently running the maximum allowed number of concurrent scans.
                let timeElapsed = CFAbsoluteTimeGetCurrent() - lastScanTime
                guard timeElapsed > timeBetweenScans,
                      scanTasks.count < MaximumConcurrentScanTasks
                else {
                    return
                }
                
                /// Reset this to the minimum time after our first scan
                timeBetweenScans = MinimumTimeBetweenScans
                
            } else {
                /// Set the last scan time
                lastScanTime = CFAbsoluteTimeGetCurrent()
                return
            }
            
            /// Set the last scan time
            lastScanTime = CFAbsoluteTimeGetCurrent()
            
            
            let (scanResult, image) = try await getScanResultAndImage(from: sampleBuffer)
//            let (image, scanResult) = try await getImageAndScanResult(from: sampleBuffer)
            await process(scanResult, for: image)
        }
    }
    
    func getScanResultAndImage(from sampleBuffer: CMSampleBuffer) async throws -> (ScanResult, UIImage) {
        /// Create the scan task and append it to the array (so we can control how many run concurrently)
        let scanTask = Task {
            let scanResult = try await FoodLabelLiveScanner(sampleBuffer: sampleBuffer).scan()
            return scanResult
        }
        scanTasks.append(scanTask)
        
        var start = CFAbsoluteTimeGetCurrent()
        
        /// Get the scan result
        let scanResult = try await scanTask.value

        print("⏰ scanResult took: \(CFAbsoluteTimeGetCurrent()-start)s")
        
        
        /// Now remove this task from the array to free up a slot for another task
        scanTasks.removeAll(where: { $0 == scanTask })
        
        /// Grab the image from the `CMSampleBuffer` and process it
//            let image = sampleBuffer.image
        
        start = CFAbsoluteTimeGetCurrent()

        guard let image = sampleBuffer.image else {
            //TODO: Throw error here instead
            fatalError("Couldn't get image")
        }

        print("⏰ image took: \(CFAbsoluteTimeGetCurrent()-start)s")
        print("⏰ ")
        
        return (scanResult, image)
    }
    
    func getImageAndScanResult(from sampleBuffer: CMSampleBuffer) async throws -> (UIImage, ScanResult) {
        var start = CFAbsoluteTimeGetCurrent()

        guard let image = sampleBuffer.image else {
            //TODO: Throw error here instead
            fatalError("Couldn't get image")
        }

        print("⏰ image took: \(CFAbsoluteTimeGetCurrent()-start)s")
        
        /// Create the scan task and append it to the array (so we can control how many run concurrently)
        let scanTask = Task {
            let scanResult = try await FoodLabelScanner(image: image).scan()
            return scanResult
        }
        scanTasks.append(scanTask)
        
        start = CFAbsoluteTimeGetCurrent()
        
        /// Get the scan result
        let scanResult = try await scanTask.value

        print("⏰ scanResult took: \(CFAbsoluteTimeGetCurrent()-start)s")
        
        /// Now remove this task from the array to free up a slot for another task
        scanTasks.removeAll(where: { $0 == scanTask })
        
        print("⏰ ")
        
        return (image, scanResult)
    }
    
    func process(_ scanResult: ScanResult, for image: UIImage) async {
        
        /// Add this result to the results set
        scanResultSets.append(scanResult, image: image)
        
        /// Attempt to get a best candidate after adding the `ScanResult` to the `scanResultSets`
        let bestResultSet = scanResultSets.bestCandidate
        
        /// Set the `boundingBox` (over which the activity indicator is shown) to either be
        /// the best candidate's bounding box, or this one's—if still not avialable
        await MainActor.run {
            
            
            withAnimation {
                foodLabelBoundingBox = bestResultSet?.scanResult.boundingBox ?? scanResult.boundingBox
                barcodeBoundingBoxes = bestResultSet?.scanResult.barcodeBoundingBoxes ?? scanResult.barcodeBoundingBoxes
            }
            
            /// If we have a best candidate avaiable—and it hasn't already been processed
            guard let bestResultSet, !didSetBestCandidate
            else {
                return
            }
            
            /// Set the `didSetBestCandidate` flag so that further invocations of these (that may happen a split-second later) don't override it
            didSetBestCandidate = true
            
//            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            Haptics.successFeedback()
            foodLabelScanHandler(bestResultSet.scanResult, bestResultSet.image)
            shouldDismiss = true
        }
    }
}

extension ScanResult {
    var barcodeBoundingBoxes: [CGRect] {
        barcodes
            .map { $0.boundingBox }
            .filter { $0 != .zero }
    }
}
