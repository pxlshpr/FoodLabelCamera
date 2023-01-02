import SwiftUI

struct InstructionsOverlay: View {

    let tappedStart: () -> ()
    
    var body: some View {
        ZStack {
//            dummyBackground
//            zstackBased
            vstackBased
        }
        .frame(width: UIScreen.main.bounds.width)
        .edgesIgnoringSafeArea(.all)
    }

    var vstackBased: some View {
        VStack {
            instructionOne
            instructionTwo
            label
                .padding(.vertical, 10)
            startButton
        }
        .padding(.top, 65)
        .padding(.bottom, 54)
    }
    
    var dummyBackground: some View {
        Image(uiImage: AssetImage(named: "background")!)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    
    var label: some View {
        Image(uiImage: AssetImage(named: "label")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
//            .frame(height: 480)
            .opacity(0.6)
            .blur(radius: 0)
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .background(
            ZStack {
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .foregroundStyle(.ultraThinMaterial)
//                        .opacity(1)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.13, to: 0.19)
                    .stroke(Color.accentColor, lineWidth: 10)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.31, to: 0.37)
                    .stroke(Color.accentColor, lineWidth: 10)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.63, to: 0.69)
                    .stroke(Color.accentColor, lineWidth: 10)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .trim(from: 0.81, to: 0.87)
                    .stroke(Color.accentColor, lineWidth: 10)
            }
        )
    }
    
    var instructionOne: some View {
        HStack {
            Image(systemName: "1.circle.fill")
                .foregroundStyle(Color(.secondaryLabel))
            Text("Make sure the food label is clearly visible")
                .foregroundColor(.secondary)
                .font(.callout)
                .fontWeight(.semibold)
                .frame(width: 250, alignment: .leading)
//                            .background(.green)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .foregroundStyle(.regularMaterial)
        )
    }
    
    var instructionTwo: some View {
        HStack {
            Image(systemName: "2.circle.fill")
                .foregroundStyle(Color(.secondaryLabel))
            Text("Keep your phone steady until the scan is complete")
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.trailing)
                .font(.callout)
                .frame(width: 250, alignment: .leading)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .foregroundStyle(.regularMaterial)
        )
    }
    
    var startButton: some View {
        Button {
            tappedStart()
        } label: {
            HStack {
                Text("Start")
            }
//                        .textCase(.uppercase)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 140, height: 40)
                .background(
                    Capsule(style: .continuous)
                        .foregroundColor(.accentColor)
                )
        }
    }
    
    //MARK: Legacy
    var zstackBased: some View {
        ZStack {
            label
            VStack {
                instructionOne
                instructionTwo
                Spacer()
            }
            .padding(.top, 65)
            VStack {
                Spacer()
                startButton
            }
            .padding(.bottom, 114)
        }
    }
}

public func AssetImage(named name: String) -> UIImage? {
    UIImage(named: name, in: Bundle.module, compatibleWith: nil)
}

struct InstructionsOverlay_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsOverlay {
            
        }
    }
}
