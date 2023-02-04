# SplitView

Arrange two SwiftUI views to sit side-by-side or above-and-below each other, 
with a draggable slider separating them to resize them. Specify the fraction of 
full width/height to position the slider, and hide/show either view. Easily 
track and persist the slider state to restore later.

NavigationSplitView is fine for a sidebar and applications that conform to a 
nice master-detail type of model. On the other hand sometimes you just need two 
views to sit side-by-side or above-and-below each other and to adjust the split 
between them. That is what SplitView does for you.

## Usage

Install the package.

The SplitView places a Splitter between the two views referred to as the `primary` 
and `secondary` views. When `SplitLayout==.Horizontal`, the 'primary' view is on the 
left, and the `secondary` is on the right. When `SplitLayout==.Vertical`, the `primary` 
is at the top, and the `secondary` is at the bottom.

I needed a way to position the Splitter when the SplitView is created and to 
control whether either of the two views was hidden. I needed to be able to control 
and save that state externally to the SplitView. I did this using two ObservableObjects: 
SplitFraction and SplitHide. 

SplitFraction holds the ratio of `primary` width/height to the overall width/height of 
the SplitView. SplitFraction only impacts the way the SplitView looks when it opens, 
but as you drag the Splitter across the SplitView, the SplitFraction is updated so 
that you can save it as needed. This way you can keep the state of the SplitView in 
something like UserDefaults, so it opens up the way you left it the last time you used it. 

SplitHide identifies the side you want to hide, if any. Its value can be either `Primary`, 
`Secondary`, or `nil`. If its value is `nil`, then both views are visible. 
SplitHide is something you might want to change externally to the SplitView, so the 
SplitView observes its value and collapses or expands the named side as you change it. 
Again, you will probably want to retain this state yourself so you can open the 
SplitView the way you left it, and SplitHide makes that easy to do.

By default, SplitView opens with the Splitter at the halfway point and both views visible.

You can use SplitView directly, but the preferred approach is to use ViewModifiers to 
split any view you are using with another. The ViewModifiers are `hSplit` and `vSplit` to 
split the view-being-modified horizontally and vertically respectively. (The example app 
includes some commented-out code to show how to use SplitView directly.)

### Simple Split Between Two Views

```
struct ContentView: View {
    var body: some View {
        Color.green.hSplit { Color.yellow }
    }
}
```

### Specifying The Initial Fraction

```
struct ContentView: View {
    let fraction = SplitFraction(0.33)
    var body: some View {
        Color.green.vSplit(fraction: fraction) { Color.yellow }
    }
}
```

### Using UserDefaults for SplitFraction and SplitHide

SplitFraction and SplitHide come with static methods to return instances that 
automatically save their values in UserDefaults. If that is not flexible enough 
for your usage, you can specify the getter/setter for their values directly.

In the example below, when you move the Splitter or hide/show, and then re-open
the app again, the view will open in the state you left it.

```
struct ContentView: View {
    let fraction = SplitFraction.usingUserDefaults(key: "splitFraction")
    let hide = SplitHide.usingUserDefaults(key: "splitHide")
    var body: some View {
        VStack(spacing: 0) {
            Button("Hide/Show") {
                withAnimation {
                    hide.toggle()
                }
            }
            Color.green.hSplit(fraction: fraction, hide: hide) { Color.yellow }
        }
    }
}
```

### Nested SplitViews

You can use the ViewModifiers to nest SplitViews, too.

```
struct ContentView: View {
    let rFraction = SplitFraction()
    let rHide = SplitHide()
    let bFraction = SplitFraction()
    let bHide = SplitHide()
    let gFraction = SplitFraction()
    let gHide = SplitHide()
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Hide/Show") {
                    withAnimation {
                        rHide.toggle()
                    }
                }
                Button("Hide/Show") {
                    withAnimation {
                        bHide.toggle()
                    }
                }
                Button("Hide/Show") {
                    withAnimation {
                        gHide.toggle()
                    }
                }
            }
            Color.red
                .hSplit(fraction: rFraction, hide: rHide) {
                    Color.blue
                        .vSplit(fraction: bFraction, hide: bHide) {
                            Color.green
                                .hSplit(fraction: gFraction, hide: gHide) {
                                    Color.yellow
                                }
                        }
                }
        }
    }
}
```

### More Realistic Example

In general, each SplitView will probably end up being a View you define yourself. A
view that is split between two others has some meaning in your application as an
entity, right? We can provide the settings used at the top-level hide/show buttons 
through the environment (although there are other ways, of course). In this case, 
our previous example, set up to retain settings in UserDefaults as they change, 
would look like this:

```
struct ContentView: View {
    let splitSettings = SplitSettings()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Hide/Show") {
                    withAnimation {
                        splitSettings.rHide.toggle()
                    }
                }
                Button("Hide/Show") {
                    withAnimation {
                        splitSettings.bHide.toggle()
                    }
                }
                Button("Hide/Show") {
                    withAnimation {
                        splitSettings.gHide.toggle()
                    }
                }
            }
            Color.red
                .hSplit(fraction: splitSettings.rFraction, hide: splitSettings.rHide) { BlueGreen() }
                .environmentObject(splitSettings)
        }
    }
}

class SplitSettings: ObservableObject {
    var rFraction = SplitFraction.usingUserDefaults(key: "rFraction")
    var rHide = SplitHide.usingUserDefaults(key: "rHide")
    var bFraction = SplitFraction.usingUserDefaults(key: "bFraction")
    var bHide = SplitHide.usingUserDefaults(key: "bHide")
    var gFraction = SplitFraction.usingUserDefaults(key: "gFraction")
    var gHide = SplitHide.usingUserDefaults(key: "gHide")
}

struct BlueGreen: View {
    @EnvironmentObject var splitSettings: SplitSettings
    var body: some View {
        Color.blue
            .vSplit(fraction: splitSettings.bFraction, hide: splitSettings.bHide) {
                SplitList()
            }
        }
}

struct SplitList: View {
    @EnvironmentObject var splitSettings: SplitSettings
    let leftItems = ["A", "B", "C", "D"]
    let rightItems = ["1", "2", "3", "4"]
    var body: some View {
        List(leftItems, id: \.self) { item in Text(item) }
            .hSplit(fraction: splitSettings.gFraction, hide: splitSettings.gHide) {
                List(rightItems, id: \.self) { item in Text(item) }
            }
    }
}
```

### Example

Clone the repo and open Example.xcworkspace. 

The example works on iOS, MacOS, and Mac Catalyst. It uses the ViewModifiers, but also 
includes commented-out code to use SplitView directly if you want to see details.

### Demo

https://user-images.githubusercontent.com/1020361/180887217-21d7bb3e-f410-43f7-8541-23e3892012b7.mov

### Issues

The only issue I am aware of is what appears to be a harmless log message when 
dragging the Splitter to cause a view size to go to zero. The message shows up in the 
Xcode console as:

```
[API] cannot add handler to 3 from 3 - dropping
```

I don't see this message when using SplitView with "real" SwiftUI views and have tried 
many different ways to prevent it, but in the end, it just seems like a harmless but 
annoying log message that is beyond the control of anyone but Apple.

### History

#### Version 0.2

Eliminates the use of the clear background and SizePreferenceKeys. (My suspicion is they were needed earlier because GeometryReader otherwise caused bad behavior, but in any case they are not needed now.) Eliminate HSplitView and VSplitView, which were themselves holding onto a SplitView. The layering was both unnecessary and not adding value other than making it explicit what kind of SplitView was being created. I concluded that the same expression was actually clearer and more concise using ViewModifiers. I also added the Example.xcworkspace.

#### Version 0.1

Originally posted in [response](https://stackoverflow.com/a/68926261) to https://stackoverflow.com/q/67403140. This version used HSplitView and VSplitView as a means to create the SplitView. It also used SizePreferenceKeys from a GeometryReader on a clear background to set the size. In nested SplitViews, I found this was causing "Bound preference ... tried to update multiple times per frame" to happen intermittently depending on the view arrangement.

