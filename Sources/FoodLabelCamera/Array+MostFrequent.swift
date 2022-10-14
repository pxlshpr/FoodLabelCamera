import Foundation

//TODO: Revisit this and make it a generic on an array of hashables after rigorous testing as we might have had issues with our first try (see below for commented out code)
func commonElementsInArrayUsingReduce(doublesArray: [Double]) -> (Double, Int) {
    let doublesArray = doublesArray.reduce(into: [:]) { (counts, doubles) in
        counts[doubles, default: 0] += 1
    }
    let element = doublesArray.sorted(by: {$0.value > $1.value}).first
    return (element?.key ?? 0, element?.value ?? 0)
}

//extension Array where Element: Hashable {
//    var mostFrequent: Element? {
//        let counts = reduce(into: [:]) { $0[$1, default: 0] += 1 }
//
//        if let (value, _) = counts.max(by: { $0.1 < $1.1 }) {
//            return value
//        }
//
//        // array was empty
//        return nil
//    }
//
//    var mostFrequentWithCount: (Element, Int)? {
//        let counts = reduce(into: [:]) { $0[$1, default: 0] += 1 }
//
//        if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
//            return (value, count)
//        }
//
//        // array was empty
//        return nil
//    }
//
//}
//
//func mostFrequent<T: Hashable>(array: [T]) -> (value: T, count: Int)? {
//
//    let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }
//
//    if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
//        return (value, count)
//    }
//
//    // array was empty
//    return nil
//}
//
//if let result = mostFrequent(array: ["a", "b", "a", "c", "a", "b"]) {
//    print("\(result.value) occurs \(result.count) times")
//}
