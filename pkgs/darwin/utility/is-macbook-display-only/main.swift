import Cocoa
import CoreGraphics
import Foundation

/// Determines if there is exactly one built-in display and, if so,
/// whether that display has a notch.
func checkDisplayStatus() -> (isSingleBuiltIn: Bool, hasNotch: Bool) {
    let screens = NSScreen.screens

    if screens.count != 1 {
        return (false, false)
    }

    let isSingleBuiltIn =
        CGDisplayIsBuiltin(
            CGDirectDisplayID(
                screens.first?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
                    as? NSNumber ?? -1
            )
        ) != 0

    var hasNotch: Bool = false

    // Check for notch using `safeAreaInsets.top`
    if #available(macOS 12.0, *) {
        let topInset = screens.first?.safeAreaInsets.top ?? 0
        let notchThreshold: CGFloat = 30.0
        hasNotch = (topInset > notchThreshold)
    }

    return (isSingleBuiltIn, hasNotch)
}

let arguments = CommandLine.arguments
let checkForNotch = arguments.contains("--and-has-notch")

let (isSingleBuiltIn, hasNotch) = checkDisplayStatus()

if checkForNotch {
    print(isSingleBuiltIn && hasNotch)
} else {
    print(isSingleBuiltIn)
}
