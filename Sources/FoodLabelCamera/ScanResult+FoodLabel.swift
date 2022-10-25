import FoodLabel
import PrepDataTypes
import FoodLabelScanner

public class ScanResultModel {
    let scanResult: ScanResult
    public init(scanResult: ScanResult) {
        self.scanResult = scanResult
    }
}

extension ScanResult {
    func nutrientRow(for attribute: Attribute) -> ScanResult.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute})
    }
    
    func value(for attribute: Attribute) -> FoodLabelValue {
        guard let row = nutrientRow(for: attribute),
              let value = row.value1 else {
            return FoodLabelValue(amount: 0)
        }
        return value
    }
}

extension ScanResultModel: FoodLabelDataSource {
    public var energyValue: FoodLabelValue {
        scanResult.value(for: .energy)
    }
    
    public var carbAmount: Double {
        scanResult.value(for: .carbohydrate).amount
    }
    
    public var fatAmount: Double {
        scanResult.value(for: .fat).amount
    }
    
    public var proteinAmount: Double {
        scanResult.value(for: .protein).amount
    }
    
    public var nutrients: [NutrientType : Double] {
        var dict: [NutrientType : Double] = [:]
        for row in scanResult.nutrients.rows {
            guard row.attribute != .energy, row.attribute != .carbohydrate, row.attribute != .fat, row.attribute != .protein,
                  let nutrientType = row.attribute.nutrientType,
                  let value = row.value1
            else {
                continue
            }
            dict[nutrientType] = value.amount
        }
        return dict
    }
    
    public var amountPerString: String {
        "1 serving"
    }
}
