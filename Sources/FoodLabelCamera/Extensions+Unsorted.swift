import Foundation
import VisionSugar
import PrepUnits
import FoodLabelScanner

extension Array where Element == ScanResultSet {
    func sortedByMostMatchesToAmountsDict(_ dict: [Attribute : (Double, Int)]) -> [ScanResultSet] {
        sorted(by: {
            $0.scanResult.countOfHowManyNutrientsMatchAmounts(in: dict)
            > $1.scanResult.countOfHowManyNutrientsMatchAmounts(in: dict)
        })
    }

    var sortedByNutrientsCount: [ScanResultSet] {
        sorted(by: { $0.scanResult.nutrientsCount > $1.scanResult.nutrientsCount })
    }
    
    func amounts(for attribute: Attribute) -> [Double] {
        compactMap { $0.scanResult.amount(for: attribute) }
    }
}

extension Array where Element == ScanResult {
    
    func sortedByMostMatchesToAmountsDict(_ dict: [Attribute : (Double, Int)]) -> [ScanResult] {
        sorted(by: {
            $0.countOfHowManyNutrientsMatchAmounts(in: dict)
            > $1.countOfHowManyNutrientsMatchAmounts(in: dict)
        })
    }
    
    var sortedByNutrientsCount: [ScanResult] {
        sorted(by: { $0.nutrientsCount > $1.nutrientsCount })
    }
    
    func amounts(for attribute: Attribute) -> [Double] {
        compactMap { $0.amount(for: attribute) }
    }
}
