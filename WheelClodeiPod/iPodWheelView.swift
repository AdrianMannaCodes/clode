import SwiftUI

/// Retro click wheel. Drag around the ring to scroll, tap the outer buttons for menu actions,
/// and tap the center for select.
struct iPodWheelView: View {
    var onScroll: (Int) -> Void
    var onMenu: () -> Void
    var onPlayPause: () -> Void
    var onNext: () -> Void
    var onPrevious: () -> Void
    var onSelect: () -> Void

    /// Degrees of rotation needed to produce one scroll step.
    private let stepDegrees: Double = 30
    @State private var lastAngle: Double?
    @State private var accumulated: Double = 0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(white: 0.96), Color(white: 0.82)],
                                         startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.25), radius: 6, y: 3)

                // Outer button labels
                Text("MENU").font(.system(size: size * 0.07, weight: .semibold))
                    .position(x: size * 0.5, y: size * 0.12)
                    .onTapGesture { onMenu() }
                Image(systemName: "playpause.fill")
                    .font(.system(size: size * 0.07))
                    .position(x: size * 0.5, y: size * 0.88)
                    .onTapGesture { onPlayPause() }
                Image(systemName: "backward.end.fill")
                    .font(.system(size: size * 0.07))
                    .position(x: size * 0.12, y: size * 0.5)
                    .onTapGesture { onPrevious() }
                Image(systemName: "forward.end.fill")
                    .font(.system(size: size * 0.07))
                    .position(x: size * 0.88, y: size * 0.5)
                    .onTapGesture { onNext() }

                // Center button
                Circle()
                    .fill(Color(white: 0.92))
                    .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                    .frame(width: size * 0.38, height: size * 0.38)
                    .onTapGesture { onSelect() }
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let center = CGPoint(x: size / 2, y: size / 2)
                        let angle = atan2(value.location.y - center.y, value.location.x - center.x) * 180 / .pi
                        guard let last = lastAngle else {
                            lastAngle = angle
                            return
                        }
                        var delta = angle - last
                        if delta > 180 { delta -= 360 }
                        if delta < -180 { delta += 360 }
                        accumulated += delta
                        lastAngle = angle
                        while accumulated >= stepDegrees {
                            accumulated -= stepDegrees
                            onScroll(1)
                        }
                        while accumulated <= -stepDegrees {
                            accumulated += stepDegrees
                            onScroll(-1)
                        }
                    }
                    .onEnded { _ in
                        lastAngle = nil
                        accumulated = 0
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
