# Contact Lenses Tracker - App Icon Design Specification

## Design Concept: Progress Ring + Contact Lens

A centered contact lens shape surrounded by a partial progress ring, set against a gradient blue background. This design creates instant recognition of both "contact lens" and "tracking progress" concepts.

## Visual Hierarchy

### Primary Element (70% visual weight)
- Contact lens shape in center
- Simplified circular form with subtle depth indicator
- White/light blue-white color with subtle gradient

### Secondary Element (25% visual weight)
- Progress ring around the lens (approximately 75% complete arc)
- Gradient from green (start) to blue (current position)
- Creates sense of ongoing tracking

### Background (5% visual weight)
- Solid or subtle gradient blue foundation
- Provides contrast and professional appearance

## Color Palette

### Light Mode Colors

```
Background Gradient:
- Top: #0A7AFF (iOS Blue - bright)
- Bottom: #0051D5 (iOS Blue - deep)

Contact Lens:
- Base: #FFFFFF (pure white)
- Highlight: #F0F9FF (subtle cool white)
- Shadow/Depth: #B8D4F1 (light blue-gray, 20% opacity)

Progress Ring:
- Start (12 o'clock): #34C759 (iOS Green)
- Progress to: #0A7AFF (iOS Blue)
- Ring thickness: 14% of icon size
- End cap: Rounded

Lens Border:
- #E5F2FF (very light blue, subtle)
- 2% of icon size in width
```

### Dark Mode Variation

```
Background Gradient:
- Top: #0051D5 (deeper blue)
- Bottom: #003D99 (darkest blue)

Contact Lens:
- Base: #F0F9FF (soft white, slightly reduced)
- Maintains visibility without glare

Progress Ring:
- Slightly increased luminosity (+10%)
- Same color progression
```

## Layout Specifications (1024x1024 base)

```
Overall Structure:
- Content Safety Margin: 102px from edges (10%)
- Active Canvas: 820x820px
- Optical Center: 512x512px

Contact Lens Element:
- Diameter: 410px (40% of canvas)
- Position: Centered at 512x512
- Shape: Circle with subtle concave indicator

Progress Ring:
- Outer Diameter: 656px (64% of canvas)
- Inner Diameter: 528px (51.5% of canvas)
- Ring Thickness: 64px
- Arc Length: 270° (75% complete)
- Start Point: 90° (3 o'clock)
- End Point: 0° (12 o'clock)
- Rotation: Clockwise
```

## 3D Effects

### Contact Lens Depth
- **Inner Shadow** (concave effect):
  - Offset Y: +8px
  - Blur: 24px
  - Color: #0A7AFF at 15% opacity

- **Highlight** (top-left):
  - Position: 30° from top
  - Gradient: Radial from #FFFFFF to transparent
  - Opacity: 40%
  - Size: 35% of lens diameter

- **Edge Definition**:
  - 1px stroke: #E5F2FF at 60% opacity

### Progress Ring Shadow
- Drop shadow for depth:
  - Offset Y: 4px
  - Blur: 12px
  - Color: #000000 at 20% opacity

## Size Optimization

### Large (512px - 1024px)
- Full detail as specified
- Subtle lens texture/reflection visible
- Progress ring gradient smooth

### Medium (180px - 512px)
- Simplify lens highlight to single ellipse
- Maintain ring gradient
- Slightly increase ring thickness (relative)

### Small (60px - 180px)
- Flatten lens to pure white circle
- Solid blue progress ring (no gradient)
- Increase contrast by 10%

### Notification (20px - 60px)
- Maximum simplification
- Consider removing progress ring
- White lens shape centered
- Higher contrast background

## iOS Icon Size Requirements

Export these sizes:
- 1024x1024 - App Store (required)
- 180x180 - iPhone App (3x)
- 120x120 - iPhone App (2x)
- 167x167 - iPad Pro
- 152x152 - iPad (2x)
- 76x76 - iPad (1x)
- 60x60 - iPhone Spotlight
- 40x40 - iPad Spotlight
- 58x58 - Settings (2x)
- 29x29 - Settings (1x)
- 20x20 - Notification (1x)

## Implementation Options

### Option 1: Design in Figma/Sketch (Recommended)
1. Create 1024x1024 artboard with gradient background
2. Draw contact lens with specified effects
3. Create progress ring with gradient stroke
4. Export all iOS size variants
5. Use PNG format, sRGB color space

### Option 2: SwiftUI Code-Based

```swift
struct AppIconShape: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [
                Color(hex: "0A7AFF"),
                Color(hex: "0051D5")
            ], startPoint: .top, endPoint: .bottom)

            // Progress ring
            Circle()
                .trim(from: 0.25, to: 1.0)
                .stroke(
                    AngularGradient(colors: [
                        Color(hex: "34C759"),
                        Color(hex: "0A7AFF")
                    ], center: .center),
                    style: StrokeStyle(lineWidth: 64, lineCap: .round)
                )
                .frame(width: 656, height: 656)
                .rotationEffect(.degrees(-90))

            // Contact lens
            Circle()
                .fill(Color.white)
                .frame(width: 410, height: 410)
                .shadow(color: Color(hex: "0A7AFF").opacity(0.15),
                       radius: 24, y: 8)
        }
        .frame(width: 1024, height: 1024)
    }
}
```

## Design Guidelines

### Do's
- Test at 60x60 pixels (most common size)
- Check against other health apps for differentiation
- Verify on light/dark backgrounds
- Mind the safe area (iOS rounds corners)
- Export in sRGB color space

### Don'ts
- Don't use photography
- Don't include text
- Don't use thin lines (minimum 2px at 1024px)
- Don't go edge-to-edge (10% margin minimum)
- Don't rely on transparency
- Don't make it too detailed

## Accessibility

**Color Contrast**:
- White lens on blue background: ~12:1 ratio (excellent)
- Works for all color vision deficiencies

**Cognitive Clarity**:
- Single clear focal point (lens)
- Secondary element (ring) supports primary
- No competing visual elements

## Why This Design?

1. **Instant Recognition**: Combines lens shape with progress tracking
2. **iOS Native Feel**: Progress rings familiar from Activity app
3. **Scalable**: Clear hierarchy at all sizes
4. **Brand Aligned**: Uses app's blue primary + status colors
5. **Unique**: Stands out from generic health/tracking apps
6. **Professional**: Modern, clean aesthetic

## Next Steps

1. Create mockup at 1024x1024 in design tool
2. Test at 60x60 by viewing on device/simulator
3. Create dark mode variant and compare
4. Export full icon set
5. Add to Xcode Assets.xcassets folder

---

*Design specification created for Contact Lenses Tracker iOS app*
