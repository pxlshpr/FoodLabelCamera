import Foundation
import VisionSugar
import PrepUnits
import FoodLabelScanner

extension Array where Element == RecognizedText {
    var boundingBox: CGRect {
        guard !isEmpty else { return .zero }
        return reduce(.null) { partialResult, text in
            partialResult.union(text.boundingBox)
        }
    }
}

extension ScanResult {
    var allTexts: [RecognizedText] {
        servingTexts + headerTexts + nutrientTexts
    }
    var servingTexts: [RecognizedText] {
        [
            serving?.amountText?.text,
            serving?.amountText?.attributeText,
            serving?.unitText?.text,
            serving?.unitText?.attributeText,
            serving?.unitNameText?.text,
            serving?.unitNameText?.attributeText,
            serving?.equivalentSize?.amountText.text,
            serving?.equivalentSize?.amountText.attributeText,
            serving?.equivalentSize?.unitText?.text,
            serving?.equivalentSize?.unitText?.attributeText,
            serving?.equivalentSize?.unitNameText?.text,
            serving?.equivalentSize?.unitNameText?.attributeText,
            serving?.perContainer?.amountText.text,
            serving?.perContainer?.amountText.attributeText,
            serving?.perContainer?.nameText?.text,
            serving?.perContainer?.nameText?.attributeText,
        ]
            .compactMap { $0 }
    }
    
    var headerTexts: [RecognizedText] {
        [
            headers?.headerText1?.text,
            headers?.headerText1?.attributeText,
            headers?.headerText2?.text,
            headers?.headerText2?.attributeText
        ]
            .compactMap { $0 }
    }
    
    var nutrientTexts: [RecognizedText] {
        var texts: [RecognizedText?] = []
        for row in nutrients.rows {
            texts.append(row.attributeText.text)
            texts.append(row.valueText1?.text)
            texts.append(row.valueText1?.attributeText)
            texts.append(row.valueText2?.text)
            texts.append(row.valueText2?.attributeText)
        }
        return texts.compactMap { $0 }
    }
}

extension ScanResult {
    
    var boundingBox: CGRect {
        allTexts
            .filter { $0.boundingBox != .zero }
            .boundingBox
    }
    
    var nutrientAttributes: [Attribute] {
        nutrients.rows.map({ $0.attribute })
    }
    
    var nutrientsCount: Int {
        nutrients.rows.count
    }
    
    var hasNutrients: Bool {
        !nutrients.rows.isEmpty
    }
    
    var resultTexts: [RecognizedText] {
        nutrientAttributeTexts
    }
    
    var nutrientAttributeTexts: [RecognizedText] {
        nutrients.rows.map { $0.attributeText.text }
    }
    
    var nutrientValueTexts: [RecognizedText] {
        nutrients.rows.map { $0.attributeText.text }
    }
    
    func amount(for attribute: Attribute) -> Double? {
        nutrients.rows.first(where: { $0.attribute == attribute })?.value1?.amount
    }
    
    func countOfHowManyNutrientsMatchAmounts(in dict: [Attribute : (Double, Int)]) -> Int {
        var count = 0
        for attribute in dict.keys {
            guard let amount = amount(for: attribute) else { continue }
            if amount == dict[attribute]?.0 {
                count += 1
            }
        }
        return count
    }
    
}

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

extension Attribute {
    var nutrientType: NutrientType? {
        NutrientType.allCases.first(where: { $0.attribute == self })
    }
}

public extension NutrientType {
    var attribute: Attribute? {
        switch self {
        case .saturatedFat:
            return .saturatedFat
        case .monounsaturatedFat:
            return .monounsaturatedFat
        case .polyunsaturatedFat:
            return .polyunsaturatedFat
        case .transFat:
            return .transFat
        case .cholesterol:
            return .cholesterol
        case .dietaryFiber:
            return .dietaryFibre
        case .solubleFiber:
            return .solubleFibre
        case .insolubleFiber:
            return .insolubleFibre
        case .sugars:
            return .sugar
        case .addedSugars:
            return .addedSugar
        case .calcium:
            return .calcium
        case .chromium:
            return .chromium
        case .iodine:
            return .iodine
        case .iron:
            return .iron
        case .magnesium:
            return .magnesium
        case .manganese:
            return .manganese
        case .potassium:
            return .potassium
        case .selenium:
            return .selenium
        case .sodium:
            return .sodium
        case .zinc:
            return .zinc
        case .vitaminA:
            return .vitaminA
        case .vitaminB6:
            return .vitaminB6
        case .vitaminB12:
            return .vitaminB12
        case .vitaminC:
            return .vitaminC
        case .vitaminD:
            return .vitaminD
        case .vitaminE:
            return .vitaminE
        case .vitaminK:
            return .vitaminK
        case .biotin:
            return .biotin
        case .folate:
            return .folate
        case .niacin:
            return .niacin
        case .pantothenicAcid:
            return .pantothenicAcid
        case .riboflavin:
            return .riboflavin
        case .thiamin:
            return .thiamin
        case .vitaminB2:
            return .vitaminB2
        case .cobalamin:
            return .cobalamin
        case .folicAcid:
            return .folicAcid
        case .vitaminB1:
            return .vitaminB1
        case .vitaminB3:
            return .vitaminB3
        case .vitaminK2:
            return .vitaminK2
        case .caffeine:
            return .caffeine
        case .taurine:
            return .taurine
        case .polyols:
            return .polyols
        case .gluten:
            return .gluten
        case .starch:
            return .starch
        case .salt:
            return .salt
            
        //TODO: Add support for these
        case .sugarAlcohols, .chloride, .copper, .molybdenum, .phosphorus, .choline, .ethanol:
            return nil
        }
    }
}

