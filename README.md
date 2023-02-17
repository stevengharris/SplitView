<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.6+-blue.svg">
    <img src="https://img.shields.io/badge/iOS-15.6+-blue.svg" alt="iOS 15.6+">
    <img src="https://img.shields.io/badge/MacCatalyst-15.6+-blue" alt="MacCatalyst 15.6+">
    <img src="https://img.shields.io/badge/Mac-12.4+-blue" alt="MacCatalyst 12.4+">
    <a href="https://mastodon.social/@stevengharris">
        <img src="https://img.shields.io/badge/Contact-@stevengharris-lightgrey.svg?style=flat" alt="Mastodon: @stevengharris@mastodon.social">
    </a>
</p>

# SplitView

A view modifier, `split`, that lets you:

* Create a single view containing two views, arranged in a horizontal (side-by-side) 
or vertical (above-and-below) `layout` separated by a draggable `splitter` for resizing.
* Specify the `fraction` of full width/height for the initial position of the splitter.
* Programmatically `hide` either view and change their `layout`.
* Arbitrarily nest split views.
* Constrain the splitter movement by specifying minimum fractions of the full width/height
for either or both views.
* Prioritize either of one the views to maintain its width/height as the containing 
view changes size.
* Easily save the state of `fraction`, `layout`, and `hide` so a split view opens 
in its last state between application restarts.
* Use your own custom `splitter` or the default Splitter.
* Make splitters "invisible" (i.e., zero `visibleThickness`) but still draggable for 
resizing.

## Motivation

NavigationSplitView is fine for a sidebar and for applications that conform to a 
nice master-detail type of model. On the other hand, sometimes you just need two 
views to sit side-by-side or above-and-below each other and to adjust the split 
between them. You also might want to compose split views in ways that make sense 
in your own application context. That is what the `split` modifier does for you.

## Demo

![SplitView](https://user-images.githubusercontent.com/1020361/219515082-6e657bee-e4e2-4efd-9e78-f5c98aaa3083.mov)

This demo is available in the Demo directory as SplitDemo.xcodeproj. 

## Usage

Install the package.

Everything is done using a single view modifier: `split`. The `split` modifier 
always requires a `layout`, either `.horizontal` or `.vertical`. 

**Note:** You *can* use the SplitView View directly, but in addition to information 
about layout and configuration, it requires three types of content to be passed-in as 
ViewBuilders. The `split` modifier makes all of that much simpler.

In its simplest form, the `split` modifier looks like this:

```
Color.red.split(.horizontal) { Color.green }
```

This will produce a horizontal split view, with red on the left and green on the right, 
with a default splitter between them that can be dragged to change their sizes. 
The view being modified - `Color.red` - is the `primary` side, and the one it is split with - 
`Color.green` - is the `secondary` side.

If you want to set the layout to be vertical and the initial position of the splitter, you 
can do this:

```
Color.red.split(.vertical, fraction: 0.25) { Color.green }
```

Now you get a red view above the green view, with the `primary` side (red) occupying 
1/4 of the window.

Often you want to hide/show one of the views you split. You can do this by specifying 
the side to hide:

```
Color.red.split(.horizontal, fraction: 0.25, hide: .secondary) { Color.green }
```

The right (green) side will be hidden, but you can pull it open using the splitter that will 
be visible on the right. This isn't usually what you want, though. Usually you want 
your users to be able to control whether a side is hidden or not. To do this, pass the 
SideHolder ObservableObject that holds onto the side you are hiding. Similarly SplitView 
comes with a FractionHolder and LayoutHolder. Under the covers, the SplitView that results 
from the `split` modifier observes all of these holders and redraws itself if they change. 

Here is an example showing how to use the SideHolder with a Button to hide/show the 
secondary (green) side:

```
struct ContentView: View {
    let hide = SideHolder()         // By default, don't hide any side
    var body: some View {
        VStack(spacing: 0) {
            Button("Toggle Hide") {
                withAnimation {
                    hide.toggle()   // Toggle between hiding nothing and hiding secondary
                }
            }
            Color.red.split(.horizontal, hide: hide) { Color.green }
        }
    }
}
```

Note that the `split` modifier accepts `hide` passed as a SplitSide - `.secondary` or `.primary` -
or as a SideHolder. Similarly, `layout` can be passed as a SplitLayout - `.horizontal` or `.vertical` - 
or as a LayoutHolder. And `fraction` can be passed as a CGFloat or as a FractionHolder.

### Nesting Split Views

The primary and/or secondary views can be SplitViews that result from the `split` modifier.
For example:

```
struct ContentView: View {
    var body: some View {
        Color.red.split(.horizontal) {
            Color.green.split(.vertical) {
                Color.blue.split(.horizontal) {
                    Color.yellow
                }
            }
        }
    }
}
```

or:

```
struct ContentView: View {
    var body: some View {
        Color.red
            .split(.horizontal) { Color.green }
            .split(.vertical) { Color.blue }
    }
}
```

A caution on the latter style... If you split a split using the same layout (i.e., both `.horizontal` or both `.vertical`) and then modify the trailing one using a HideHolder or LayoutHolder, the entire view body will be regenerated. This can result in some jagged animation.

### Using UserDefaults for Split State

The three holders - SideHolder, LayoutHolder, and FractionHolder - all come with a 
static method to return instances that get/set their state from UserDefaults.standard. 
Let's expand the previous example to be able to change the `layout` and `hide` state 
and to get/set their values from UserDefaults. The first time you open this, the sides 
will be split 50-50, but as you drag the splitter, the `fraction` state is also retained 
in UserDefaults.standard.

```
struct ContentView: View {
    let fraction = FractionHolder.usingUserDefaults(0.5, key: "myFraction")
    let layout = LayoutHolder.usingUserDefaults(.horizontal, key: "myLayout")
    let hide = SideHolder.usingUserDefaults(key: "mySide")
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Toggle Layout") {
                    withAnimation {
                        layout.toggle()
                    }
                }
                Button("Toggle Hide") {
                    withAnimation {
                        hide.toggle()
                    }
                }
            }
            Color.red.split(layout, fraction: fraction, hide: hide) { Color.green }
        }
    }
}
```

You can change the `layout` and hide/show the green view, and when you next open the app, 
they will be restored how you left them. Similarly, if you moved the splitter around, 
when you open the app again, it will open where you left it.

### Modifying and Constraining the Default Splitter 

You can change the way the default Splitter displays using SplitConfig. Pass the SplitConfig 
to the `split` modifier. For example, you can change the color, inset, and thickness:

```
let config = SplitConfig(color: Color.cyan, inset: 4, visibleThickness: 8)
Color.red.split(.vertical, fraction: 0.25, config: config) { Color.green }
```

By default, the splitter can be dragged across the full width/height of the split 
view. SplitConfig also lets you constrain the minimum faction of the overall view 
that the `primary` and/or `secondary` view occupies, so the splitter always stays 
within those constraints. You can do this by specifying `minPFraction` and/or 
`minSFraction` in SplitConfig:

```
let config = SplitConfig(color: Color.cyan, minPFraction: 0.2, minSFraction: 0.2)
Color.red.split(.vertical, fraction: 0.25, config: config) { Color.green }
```

One thing to note is that if you specify `minPFraction` or `minSFraction`, then when 
you hide a side that has its minimum fraction specified, you won't be able to drag 
it out from its hidden state. Why? Because it doesn't make sense to be able to drag 
from the hidden side when you never could have dragged it to that location to begin 
with because of the fraction constraint. As soon as you tried to drag it, the slider 
would snap to an allowed position, which is also jarring to users. To make sure 
there is no visual confusion about whether a splitter can be dragged, the splitter 
will not shown at all when it is not draggable. Again: a splitter will only be 
non-draggable when a side is hidden and the corresponding `minPFraction` or 
`minSFraction` is specified.

### Custom Splitters

By default the `split` modifier produces a SplitView that uses the default Splitter. You can 
create your own and use it, though. Your custom splitter has to conform to SplitDivider 
protocol, which makes sure your custom splitter can let the SplitView know what its 
`visibleThickness` is. The `visibleThickness` is the size your custom splitter displays 
itself in, and it also defines the `spacing` between the `primary` and `secondary` views inside 
of SplitView.

The SplitView detects drag events occurring in the splitter. For this reason, you might want 
to use a ZStack with an underlying Color.clear that represents the "invisibleThickness" if 
the `visibleThickness` is too small for properly detecting the drag events.

Here is an example custom splitter whose contents is sensitive to the observed `layout` 
and `hide` state:

```
struct CustomSplitter: SplitDivider {
    var visibleThickness: CGFloat = 20
    @ObservedObject var layout: LayoutHolder
    @ObservedObject var hide: SideHolder
    let hideRight = Image(systemName: "arrowtriangle.right.square")
    let hideLeft = Image(systemName: "arrowtriangle.left.square")
    let hideDown = Image(systemName: "arrowtriangle.down.square")
    let hideUp = Image(systemName: "arrowtriangle.up.square")
    
    var body: some View {
        if layout.isHorizontal {
            ZStack {
                Color.clear
                    .frame(width: 30)   // Larger than the visibleThickness
                    .padding(0)
                Button(
                    action: { withAnimation { hide.toggle() } },
                    label: {
                        hide.value == nil ? hideRight.imageScale(.large) : hideLeft.imageScale(.large)
                    }
                )
                .buttonStyle(.borderless)
            }
            .contentShape(Rectangle())
        } else {
            ZStack {
                Color.clear
                    .frame(height: 30)
                    .padding(0)
                Button(
                    action: { withAnimation { hide.toggle() } },
                    label: {
                        hide.value == nil ? hideDown.imageScale(.large) : hideUp.imageScale(.large)
                    }
                )
                .buttonStyle(.borderless)
            }
            .contentShape(Rectangle())  // So the drag event is detected for the entire splitter
        }
    }
    
}
``` 

You can use the CustomSplitter like this:

```
struct ContentView: View {
    let layout = LayoutHolder()
    let hide = SideHolder()
    var body: some View {
        Color.red
            .split(
                layout,
                hide,
                splitter: { CustomSplitter(layout: layout, hide: hide) },
                secondary: { Color.green }
            )
    }
}
```

If you make a custom splitter that would be generally useful to people, *please* file 
a pull request and include an additional Splitter extension in Splitter+Extensions.swift. 
The `line` Splitter is included in the file as an example that is used in the "Sidebars" 
demo. Similarly, the `invisible` Splitter re-uses the `line` splitter by passing a 
`visibleThickness` of zero and is used in the "Invisible splitter" demo.

### Invisible Splitters

You might want the views you split to be adjustable using the splitter, but for the splitter 
itself to be invisible. For example, a "normal" sidebar doesn't show a splitter between it 
and the detail view it sits next to. You can do this passing `Splitter.invisible()` as the 
custom splitter.

One thing to watch out for with an invisible splitter is that when a side is hidden, there 
is no visual indication that it can be dragged back out. To prevent this issue, you should 
specify `minPFraction` and `midSFraction` when using `Splitter.invisible()`.

```
struct ContentView: View {
    let hide = SideHolder()
    let config = SplitConfig(minPFraction: 0.2, minSFraction: 0.2)
    var body: some View {
        VStack(spacing: 0) {
            Button("Toggle Hide") {
                withAnimation {
                    hide.toggle()   // Toggle between hiding nothing and hiding secondary
                }
            }
            Color.red
                .split(
                    .horizontal,
                    hide: hide,
                    config: config,
                    splitter: { Splitter.invisible(.horizontal) },
                    secondary: { Color.green }
                )
        }
    }
}
```

### Prioritizing The Size Of A Side

When you have a `.horizontal` layout in a sidebar type of arrangement of split views, 
you often want the sidebar to maintain its width as you resize the overall view. 
You might have the same need for a `.vertical` layout also. If you have two sidebars, 
you may want to slide either one while the opposing one stays the same width. You 
can accomplish this by specifying a `priority` side (either `.primary` or `.secondary`)
in the SplitConfig.

Here is an example that has a red left sidebar and green right sidebar surrounding a 
yellow middle view. As you slide either splitter, the other stays fixed. Under the covers, 
the SplitView is adjusting the proportion between `primary` and `secondary` to keep the 
splitter in the same place. You will also see that as you resize the window, both 
sidebars maintain their width.

```
struct ContentView: View {
    var body: some View {
        let leftConfig = SplitConfig(priority: .primary)
        let rightConfig = SplitConfig(priority: .secondary)
        Color.red.split(.horizontal, fraction: 0.2, config: leftConfig) {
            Color.yellow.split(.horizontal, fraction: 0.75, config: rightConfig) {
                Color.green
            }
        }
    }
}
```

## Issues

The only issue I am aware of is what appears to be a harmless log message when 
dragging the Splitter to cause a view size to go to zero. The message shows up in the 
Xcode console as:

```
[API] cannot add handler to 3 from 3 - dropping
```

I don't see this message when using SplitView with "real" SwiftUI views and have tried 
many different ways to prevent it, but in the end, it just seems like a harmless but 
annoying log message that is beyond the control of anyone but Apple.

## Possible Enhancements

I might add a few things but would be very happy to accept pull requests! For example,
a split view that adapted to device orientation and form factors somewhat like 
NavigationSplitView would be useful.

## History

### Version 2.0

* Incompatible change from Version 1 in split enums. SplitLayout cases change from `.Horizontal` and `.Vertical` to `.horizontal` and `.vertical`. SplitSide cases change from `.Primary` and `.Secondary` to `.primary` and `.secondary`.
* Add ability to specify a side (`.primary` or `.secondary`) that has sizing `priority`. The size of the `priority` side remains unchanged as its containing view resizes. If `priority` is not specified - the default - then the proportion between `primary` and `secondary` is maintained. This enables proper sidebar type of behavior, where changing one sidebar's size does not affect the other.
* Add a sidebar demo showing the use of `priority`.

### Version 1.1

* Generalize the way configuration of SplitView properties are handled using SplitConfig, which can optionally be passed to the `split` modifier. 
There is a minor compatibility change in that properties such as `color` and `visibleThickness` must be passed to the default Splitter using SplitConfig.
* Allow minimum fractions - `minPFraction` and `minSFraction` - to be configured in SplitConfig to constrain the size of the `primary` and/or `secondary` views.
* If a minimum fraction is specified for a side and that side is hidden, then the splitter will be hidden, too. The net effect of this change is 
that the hidden side cannot be dragged open when it is hidden and a minimum fraction is specified for a side. It can still be unhidden by 
changing its SideHolder. Under these conditions, the unhidden side occupies the full width/height when the other is hidden, without any inset 
for the splitter.

### Version 1.0

Make layout adjustable. Clean up and formalize the SplitDemo, including the custom splitter and "invisible" splitter. Update the README.

### Version 0.2

Eliminates the use of the clear background and SizePreferenceKeys. (My suspicion is they were needed earlier because GeometryReader otherwise caused bad behavior, but in any case they are not needed now.) Eliminate HSplitView and VSplitView, which were themselves holding onto a SplitView. The layering was both unnecessary and not adding value other than making it explicit what kind of SplitView was being created. I concluded that the same expression was actually clearer and more concise using ViewModifiers. I also added the Example.xcworkspace.

### Version 0.1

Originally posted in [response](https://stackoverflow.com/a/68926261) to https://stackoverflow.com/q/67403140. This version used HSplitView and VSplitView as a means to create the SplitView. It also used SizePreferenceKeys from a GeometryReader on a clear background to set the size. In nested SplitViews, I found this was causing "Bound preference ... tried to update multiple times per frame" to happen intermittently depending on the view arrangement.

