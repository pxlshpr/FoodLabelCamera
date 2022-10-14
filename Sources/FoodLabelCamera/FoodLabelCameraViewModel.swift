import AVKit
import SwiftUI
import FoodLabelScanner
import SwiftHaptics

public typealias FoodLabelScanHandler = (ScanResult, UIImage) -> ()

class FoodLabelCameraViewModel: ObservableObject {

    /// Tweak this if needed, but these current values result in the least dropped frames with the quickest response time on the iPhone 13 Pro Max
    let MinimumTimeBetweenScans = 0.5
    let MaximumConcurrentScanTasks = 3
    
    let scanResultsSet = ScanResultsSet()
    @Published var boundingBox: CGRect? = nil
    @Published var didSetBestCandidate = false
    @Published var shouldDismiss = false

    var scanTasks: [Task<ScanResult, Error>] = []
    var lastScanTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    
    let foodLabelScanHandler: FoodLabelScanHandler
    
    init(foodLabelScanHandler: @escaping FoodLabelScanHandler) {
        self.foodLabelScanHandler = foodLabelScanHandler
    }
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        Task {
            /// Make sure enough time since the last scan has elapsed, and we're not currently running the maximum allowed number of concurrent scans.
            let timeElapsed = CFAbsoluteTimeGetCurrent() - self.lastScanTime
            guard timeElapsed > MinimumTimeBetweenScans,
                  scanTasks.count < MaximumConcurrentScanTasks
            else {
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
            let image = sampleBuffer.image
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
                boundingBox = bestScanResult?.boundingBox ?? scanResult.boundingBox
            }
            
            /// If we have a best candidate avaiable—and it hasn't already been processed
            guard let bestScanResult, !didSetBestCandidate
            else {
                return
            }
            
            /// Set the `didSetBestCandidate` flag so that further invocations of these (that may happen a split-second later) don't override it
            didSetBestCandidate = true
            
            Haptics.successFeedback()
            foodLabelScanHandler(bestScanResult, image)
            shouldDismiss = true
        }
    }
}
