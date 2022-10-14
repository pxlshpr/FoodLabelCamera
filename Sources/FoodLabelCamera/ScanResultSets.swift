import SwiftUI
import FoodLabelScanner

class ScanResultSets: ObservableObject {
    
    var array: [ScanResultSet] = []
    var mostFrequentAmounts: [Attribute: (Double, Int)] = [:]

    func append(_ scanResult: ScanResult, image: UIImage) {
//        guard scanResult.hasNutrients else {
//            return
//        }
        let scanResultSet = ScanResultSet(scanResult: scanResult, image: image)
        array.append(scanResultSet)
    }
    
    var barcodeCandidate: ScanResultSet? {
        /// Return the first `ScanResult` that has no nutrients but barcodes
        array.first(where: { !$0.scanResult.hasNutrients && !$0.scanResult.barcodes.isEmpty })
    }
    
    var bestCandidate: ScanResultSet? {
        
//        /// if we have a barcode candidate (barcode with no nutrients)—return that immediately
//        if let barcodeCandidate {
//            return barcodeCandidate
//        }
        
        guard array.count >= 3,
              let withMostNutrients = array.sortedByNutrientsCount.first
        else {
            return nil
        }
        
        /// for each nutrient, save the most-frequent value across all these results
        for attribute in withMostNutrients.scanResult.nutrientAttributes {
            let doubles = array.amounts(for: attribute)
            let mostFrequentWithCount = commonElementsInArrayUsingReduce(doublesArray: doubles)
            mostFrequentAmounts[attribute] = mostFrequentWithCount
        }
        
        /// now sort the filtered results by the count of (how many nutrients in it match the modal results) and return the first one
        let sorted = array
            .sortedByMostMatchesToAmountsDict(mostFrequentAmounts)
//            .sorted { $0.date > $1.date }
        
        /// return the one with the most matches
        return sorted.first
    }
}

extension ScanResultSets {
    //TODO: Revisit this
    /// What we were doing here—counting how many times the same `ScanResult` was being received, and then later sorting the results by choosing the latest `ScanResult` that had the most matches. Might be redundant as we're currently waiting as little time as possible before returning.
//    func bestCandidateAfterAdding(result: ScanResult) -> ScanResultSet? {
//        guard result.hasNutrients else { return nil }
//        /// If we have a `ScanResult` that matches this
//        if let index = array.firstIndex(where: { $0.scanResult.matches(result) }) {
//            let existing = array.remove(at: index)
//
//            /// Replace the scan result with the new one (so we always keep the latest copy)
//            existing.scanResult = result
//
//            /// Update the date
//            existing.date = Date()
//
//            /// Increase the count
//            existing.count += 1
//
//            array.append(existing)
//        } else {
//            array.append(ScanResultSet(scanResult: result, image: nil))
//        }
//
//        return bestCandidate
//    }
}

