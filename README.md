# SplitView

Split view for SwiftUI with a slider to adjust the split size.

Originally posted in response to https://stackoverflow.com/a/68926261/8968411

### Usage

Install the package or just grab the SplitView.swift and Splitter.swift.

Although there is a SplitView class, use the HSplitView and VSplitView, identifying 
the primary and secondary views. The primary view is the one on top in a VSplitView 
and the one on the left in the HSplitView.

#### Using defaults

A split view defaults to a 50-50 split.

```
import SwiftUI

struct ContentView: View {
    var body: some View {
        HSplitView(
            primary: { HSplitView( primary: { Color.red }, secondary: { Color.green }) },
            secondary: { VSplitView( primary: { Color.blue }, secondary: { Color.white }) }
        )
    }
}
```

#### Options

You can specify the fraction to open-with as a binding, so you can get/set it from your 
app state and track it as it changes. You may need to specify a zIndex for the split 
view in cases of split views containing split views, so that the invisibleThickness used 
to give a wider drag area is effective for the complete slider length.

There is some limited availability to customize the Slider with visibleThickness and 
invisibleThickness. The secondaryHidden binding allows you to open the split view with 
the secondary view closed. In that case, the slider is still visible to drag it open. 
You can use secondaryHidden as a means to collapse the secondary (for example, to hide/show 
a side or bottom panel that your user might then resize).

```
import SwiftUI

struct ContentView: View {
    var body: some View {
        HSplitView(
            zIndex: 2,
            fraction: .constant(0.75),
            primary: { Color.red },
            secondary: {
                VSplitView(
                    zIndex: 1,
                    primary: { Color.blue },
                    secondary: {
                        VSplitView(
                            zIndex: 0,
                            primary: { Color.green },
                            secondary: { Color.yellow }
                        )
                    }
                )
            }
        )
    }
}
```

### Demo

![](https://user-images.githubusercontent.com/1020361/180887217-21d7bb3e-f410-43f7-8541-23e3892012b7.mov | width=300)
