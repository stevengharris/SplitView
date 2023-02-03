# SplitView

Split view for SwiftUI with a slider to adjust the split size.

Originally posted in response to https://stackoverflow.com/a/68926261/8968411, 
but extensively reworked and simplified.

## Usage

Install the package.

The SplitView places a Splitter between the two views referred to as the `primary` 
and `secondary` views. When `SplitLayout==.Horizontal`, the 'primary' view is on the 
left, and the `secondary` is on the right. When `SplitLayout==.Vertical`, the `primary` 
is at the top, and the `secondary` is at the bottom.

I needed a way to position the Splitter when the SplitView is created and to 
control whether either of the two views was hidden. I needed to be able to control 
and save that state externally to the SplitView. I did this using two ObservableObjects: 
SplitFraction and SplitHide. The SplitFraction only impacts the way the 
SplitView looks when it opens, but as you drag the Splitter across the SplitView, 
the SplitFraction is updated so that you can save it as needed. This way you can 
keep the state of the SplitView in something like UserDefaults, so it opens up the 
way you left it the last time you used it. 

SplitHide identifies the side you want to hide, if any. Its value can be either `Primary`, 
`Secondary`, or `nil`. If its value is `nil`, then both views are visible. 
SplitHide is something you might want to change externally to the SplitView, so the 
SplitView observes its value and collapses or expands the named side as you change it. 
Again, you will probably want to retain this state yourself so you can open the 
SplitView the way you left it, and SplitHide makes that easy to do.

By default, SplitView opens with the Splitter at the halfway point and both views visible.

You can use SplitView directly, but the better approach is to use ViewModifiers to split 
any view you are using with another. The ViewModifiers are `hSplit` and `vSplit` to 
split the view-being-modified horizontally and vertically respectively.

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
    let gHide = SplitHide(.Primary) // Hide the primary view at open
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

### Issues

The only issue I am aware of is what appears to be a harmless log message when 
dragging the Splitter to cause a view size to go to zero. The message shows up in the 
Xcode console as:

```
[API] cannot add handler to 3 from 3 - dropping
```

I don't see this message when using SplitView with "real" SwiftUI views and have tried 
many different ways to prevent it, but in the end, it just seems like a harmless but 
annoying log message.

### Demo

https://user-images.githubusercontent.com/1020361/180887217-21d7bb3e-f410-43f7-8541-23e3892012b7.mov
