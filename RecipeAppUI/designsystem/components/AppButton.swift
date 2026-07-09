import SwiftUI

enum ButtonVariant{
    case primaryFilled
    case secondaryTextFilled
    case primaryOutlined
    case secondaryTextOutlined
    case secondaryFilled
}

enum ButtonSize{
    case regular
    case small
}

struct AppButton: View {
    let title: String
    let variant: ButtonVariant
    let size: ButtonSize
    var icon: String? = nil
    var font: Font = .h3
    var action: () -> Void

    var body: some View {
        Button(action: action){
            HStack(spacing: 8){
                if let icon {
                    Image(icon)
                }
                Text(title)
                    .font(font)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(color)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(borderColor, lineWidth: 1.5))
        }
        
       
    }
    private var color: Color{
        switch variant{
            case .primaryFilled:
            return Color(.appPrimary)
            case .secondaryTextFilled:
            return Color(.appForm)
            case .primaryOutlined:
                return .clear
            case .secondaryFilled:
            return Color(.appSecondary)
            case .secondaryTextOutlined:
                return .clear
            }
        }
        
        private var textColor: Color{
            switch variant{
            case .primaryFilled:
                return .white
            case .secondaryFilled:
                return .white
            case .primaryOutlined:
                return Color(.appPrimary)
            case .secondaryTextOutlined:
                return .black
            case .secondaryTextFilled:
                return .appSecondaryText
            }
        }
        
        private var borderColor: Color{
            switch variant{
            case .primaryOutlined:
                return Color(.appPrimary)
            case .secondaryTextOutlined:
                return Color(.appOutline)
            case .secondaryFilled:
                return Color(.appSecondary)
            default:
                return .clear
            }
        }
        
        private var height: CGFloat {
            size == .regular ? 56 : 48
        }
}

#Preview {
    AppButton(
        title: "Test",
        variant: .primaryFilled,
        size: .regular,
        icon: "heart",
        font: .h1,
        action: {
            
        }
    )
}
