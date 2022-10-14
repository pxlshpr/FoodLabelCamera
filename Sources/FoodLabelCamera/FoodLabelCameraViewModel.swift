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
    
    let scanResultsSet = ScanResultsSet()
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
            
            /// Create the scan task and append it to the array (so we can control how many run concurrently)
            let scanTask = Task {
                let scanResult = try await FoodLabelLiveScanner(sampleBuffer: sampleBuffer).scan()
                return scanResult
            }
            scanTasks.append(scanTask)
            
            /// Get the scan result
            let scanResult = try await scanTask.value
            /// Now remove this task from the array to free up a slot for another task
            scanTasks.removeAll(where: { $0 == scanTask })
            
            /// Grab the image from the `CMSampleBuffer` and process it
//            let image = sampleBuffer.image
            
            guard let image = sampleBuffer.image else {
                //TODO: Throw error here instead
                fatalError("Couldn't get image")
            }
            
            await process(scanResult, for: image)
        }
    }
    
    func process(_ scanResult: ScanResult, for image: UIImage) async {
        
        /// Add this result to the results set
        scanResultsSet.append(scanResult)
        
        /// Attempt to get a best candidate after adding the `ScanResult` to the `ScanResultsSet`
        let bestScanResult = scanResultsSet.bestCandidate
        
        /// Set the `boundingBox` (over which the activity indicator is shown) to either be
        /// the best candidate's bounding box, or this one's—if still not avialable
        await MainActor.run {
            
            
            withAnimation {
                foodLabelBoundingBox = bestScanResult?.boundingBox ?? scanResult.boundingBox
                barcodeBoundingBoxes = bestScanResult?.barcodeBoundingBoxes ?? scanResult.barcodeBoundingBoxes
            }
            
            /// If we have a best candidate avaiable—and it hasn't already been processed
            guard let bestScanResult, !didSetBestCandidate
            else {
                return
            }
            
            /// Set the `didSetBestCandidate` flag so that further invocations of these (that may happen a split-second later) don't override it
            didSetBestCandidate = true
            
//            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            Haptics.successFeedback()
            foodLabelScanHandler(bestScanResult, image)
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
