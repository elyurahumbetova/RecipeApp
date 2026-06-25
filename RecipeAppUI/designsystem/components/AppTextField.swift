import SwiftUI

enum TextFieldType {
    case email
    case password
    case other(placeholder: String, leadingIcon: String?)
}

struct AppTextField: View {

    var type: TextFieldType
    @Binding var text: String

    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false

    var axis : Axis = .horizontal
    private var placeholder: String {
        switch type {
        case .email:             return "Email address"
        case .password:          return "Password"
        case .other(let ph, _):  return ph
        }
    }

    private var leadingIcon: String? {
        switch type {
        case .email:              return "envelope"
        case .password:           return "lock"
        case .other(_, let icon): return icon
        }
    }

    private var borderColor: Color {
        isFocused || !text.isEmpty ? Color(.appPrimary) : Color(.appOutline)
    }

    private var trailingIcon: String? {
        switch type {
        case .password:
            return isPasswordVisible ? "eye.slash" : "eye"
        case .email:
            return !text.isEmpty ? "checkmark.circle.fill" : nil
        case .other:
            return nil
        }
    }

    var body: some View {
        HStack(spacing: 10) {

            if let icon = leadingIcon {
                Image(systemName: icon)
                    .foregroundStyle(isFocused ? Color(.appPrimary) : Color(.appOutline))
                    .frame(width: 24)
            }
          
            // Text input
            Group {
                if case .password = type, !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text,axis : axis)
                        .keyboardType(type == .email ? .emailAddress : .default)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(type == .email ? .never : .sentences)
                }
            }
            .focused($isFocused)

            if let icon = trailingIcon {
                Button {
                    if case .password = type {
                        isPasswordVisible.toggle()
                    }
                } label: {
                    Image(systemName: icon)
                        .foregroundStyle(
                            type == .email
                                ? Color(.appPrimary)
                                : Color(.appOutline)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 32)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

extension TextFieldType: Equatable {
    static func == (lhs: TextFieldType, rhs: TextFieldType) -> Bool {
        switch (lhs, rhs) {
        case (.email, .email), (.password, .password): return true
        case (.other(let a, _), .other(let b, _)):     return a == b
        default: return false
        }
    }
}

#Preview {
    PreviewWrapper()
}

struct PreviewWrapper: View {
    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            AppTextField(type: .email, text: $email)
            AppTextField(type: .password, text: $password)
            AppTextField(type: .other(placeholder: "Username", leadingIcon: "person"), text: $email)
        }
        .padding()
    }
}
