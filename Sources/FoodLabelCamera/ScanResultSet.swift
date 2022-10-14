import SwiftUI
import FoodLabelScanner

class ScanResultSet: ObservableObject {
    var scanResult: ScanResult
    var date: Date = Date()
    var image: UIImage?
    
    /// How many times this has been repeated
    var count: Int
    
    init(scanResult: ScanResult, image: UIImage? = nil) {
        self.scanResult = scanResult
        self.image = image
        self.count = 0
    }
}
