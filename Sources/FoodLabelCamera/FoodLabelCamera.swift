import SwiftUI
import SwiftHaptics
import ActivityIndicatorView
import Camera

public struct FoodLabelCamera: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var cameraViewModel: CameraViewModel
    @StateObject var viewModel: FoodLabelCameraViewModel
    
    public init(foodLabelScanHandler: @escaping FoodLabelScanHandler) {
        
        let viewModel = FoodLabelCameraViewModel(foodLabelScanHandler: foodLabelScanHandler)
        _viewModel = StateObject(wrappedValue: viewModel)
        
        let cameraViewModel = CameraViewModel(
            mode: .scan,
            shouldShowScanOverlay: false,
            showDismissButton: true,
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
            if !viewModel.started {
                InstructionsOverlay(tappedStart: tappedStart)
            }
            detectedRectanglesLayer
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
        .onChange(of: cameraViewModel.shouldDismiss) { newShouldDismiss in
            if newShouldDismiss {
                dismiss()
            }
        }
    }
    
    func tappedStart() {
        Haptics.feedback(style: .heavy)
        withAnimation {
            cameraViewModel.shouldShowScanOverlay = true
            viewModel.started = true
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

    @ViewBuilder
    var detectedRectanglesLayer: some View {
        if let detectedRectangleBoundingBox = viewModel.detectedRectangleBoundingBox {
            GeometryReader { geometry in
                boxLayer(
                    boundingBox: detectedRectangleBoundingBox,
                    inSize: geometry.size,
                    color: Color.primary,
                    opacity: 0.4
                )
            }
        }
    }

    var barcodeBoxesLayer: some View {
        ForEach(viewModel.barcodeBoundingBoxes.indices, id: \.self) { index in
            GeometryReader { geometry in
                boxLayer(
                    boundingBox: viewModel.barcodeBoundingBoxes[index],
                    inSize: geometry.size,
                    color: Color(.label),
//                    activityType: .equalizer(count: 10)
                    activityType: .arcs(count: 5, lineWidth: 10)
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
                    color: viewModel.didSetBestCandidate ? .green : Color(.label),
                    activityType: .arcs(count: 5, lineWidth: 10)
                )
            }
        }
    }
    
    func boxLayer(boundingBox: CGRect, inSize size: CGSize, color: Color, opacity: CGFloat = 0, activityType: ActivityIndicatorView.IndicatorType? = nil) -> some View {
        @ViewBuilder
        var overlayView: some View {
            if let activityType {
//                ActivityIndicatorView(isVisible: .constant(true), type: .equalizer(count: 6))
                ActivityIndicatorView(isVisible: .constant(true), type: activityType)
//                ActivityIndicatorView(isVisible: .constant(true), type: .arcs())
                    .frame(width: 80, height: 80)
                    .foregroundColor(
                        Color.accentColor.opacity(0.7)
                    )
            }
        }
        
        var box: some View {
            RoundedRectangle(cornerRadius: 3)
                .foregroundStyle(
                    color.gradient.shadow(
                        .inner(color: .black, radius: 3)
                    )
                )
                .opacity(opacity)
                .frame(width: boundingBox.rectForSize(size).width,
                       height: boundingBox.rectForSize(size).height)
            
                .overlay(overlayView)
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
