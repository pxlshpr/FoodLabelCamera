import SwiftUI
import SwiftHaptics
import ActivityIndicatorView
import Camera

public struct FoodLabelCamera: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var cameraViewModel: CameraViewModel
    @StateObject var viewModel: FoodLabelCameraViewModel
    let foodLabelScanHandler: FoodLabelScanHandler
    
    public init(foodLabelScanHandler: @escaping FoodLabelScanHandler) {
        self.foodLabelScanHandler = foodLabelScanHandler
        
        let viewModel = FoodLabelCameraViewModel(foodLabelScanHandler: foodLabelScanHandler)
        _viewModel = StateObject(wrappedValue: viewModel)
        
        let cameraViewModel = CameraViewModel(
            mode: .scan,
            showFlashButton: false,
            showTorchButton: true,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _cameraViewModel = StateObject(wrappedValue: cameraViewModel)
    }
    
    public var body: some View {
        ZStack {
            cameraLayer
            GeometryReader { geometry in
                boxesLayer
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onChange(of: viewModel.shouldDismiss) { newShouldDismiss in
            if newShouldDismiss {
                dismiss()
            }
        }
    }
    
    //MARK: - Layers
    var cameraLayer: some View {
        BaseCamera(sampleBufferHandler: viewModel.processSampleBuffer)
            .environmentObject(cameraViewModel)
    }
    

    var boxesLayer: some View {
        ZStack {
            textBoxesLayer
            barcodeBoxesLayer
        }
    }
    
    var barcodeBoxesLayer: some View {
        ForEach(viewModel.barcodeBoundingBoxes.indices, id: \.self) { index in
            GeometryReader { geometry in
                boxLayer(
                    boundingBox: viewModel.barcodeBoundingBoxes[index],
                    inSize: geometry.size,
                    color: Color(.label)
                )
            }
        }
    }
    
    @ViewBuilder
    var textBoxesLayer: some View {
        if let boundingBox = viewModel.foodLabelBoundingBox {
            GeometryReader { geometry in
                boxLayer(
                    boundingBox: boundingBox,
                    inSize: geometry.size,
                    color: viewModel.didSetBestCandidate ? .green : Color(.label)
                )
            }
        }
    }
    
    func boxLayer(boundingBox: CGRect, inSize size: CGSize, color: Color) -> some View {
        var box: some View {
            RoundedRectangle(cornerRadius: 3)
                .foregroundStyle(
                    color.gradient.shadow(
                        .inner(color: .black, radius: 3)
                    )
                )
                .opacity(0.4)
                .opacity(0)
                .frame(width: boundingBox.rectForSize(size).width,
                       height: boundingBox.rectForSize(size).height)
            
                .overlay(
                    ActivityIndicatorView(isVisible: .constant(true), type: .equalizer(count: 6))
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)
                )
                .shadow(radius: 3, x: 0, y: 2)
        }
        
        return HStack {
            VStack(alignment: .leading) {
                box
                Spacer()
            }
            Spacer()
        }
        .offset(x: boundingBox.rectForSize(size).minX,
                y: boundingBox.rectForSize(size).minY)
    }
}
