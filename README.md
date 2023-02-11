<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.6-blue.svg">
    <img src="https://img.shields.io/badge/iOS-15.6+-blue.svg" alt="iOS 15.6+">
    <img src="https://img.shields.io/badge/MacCatalyst-15.6-blue" alt="MacCatalyst 15.6+">
    <img src="https://img.shields.io/badge/Mac-12.4-blue" alt="MacCatalyst 12.4+">
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
* Easily save the state of `fraction`, `layout`, and `hide` so a split view opens 
in its last state between application restarts.
* Create and use your own custom `splitter`.
* Make splitters "invisible" (i.e., zero `visibleThickness`) but still draggable for 
resizing.

## Motivation

NavigationSplitView is fine for a sidebar and for applications that conform to a 
nice master-detail type of model. On the other hand sometimes you just need two 
views to sit side-by-side or above-and-below each other and to adjust the split 
between them. That is what the `split` modifier does for you.

## Demo

![SplitView](https://user-images.githubusercontent.com/1020361/218280797-72c796eb-e78c-415b-a6a3-6d49b3e39e72.mov)

This demo is available in the Demo directory as SplitDemo.xcodeproj. 

## Usage

Install the package.

Everything is done using a single view modifier: `split`. The `split` modifier 
always requires a `layout`, either `.Horizontal` or `.Vertical`. 

**Note:** You *can* use the SplitView View directly, but in addition to information 
about layout, it requires three types of content to be passed-in as ViewBuilders, and 
the `split` modifier makes all of that much simpler.

In its simplest form, the `split` modifier looks like this:

```
Color.red.split(.Horizontal) { Color.green }
```

This will produce a horizontal split view, with red on the left and green on the right, 
with a default splitter between them that can be dragged to change their sizes. 
The view being modified - Color.red - is the `Primary` side, and the one it is split with - 
Color.green - is the `Secondary` side.

If you want to set the layout to be vertical and the initial position of the splitter, you 
can do this:

```
Color.red.split(.Vertical, fraction: 0.25) { Color.green }
```

Now you get a red view above the green view, with the `Primary` side (red) occupying 
1/4 of the window.

Often you want to hide/show one of the views you split. You can do this by specifying 
the side to hide:

```
Color.red.split(.Horizontal, fraction: 0.25, hide: .Secondary) { Color.green }
```

The right (green) side will be hidden, but you can pull it open using the splitter that will 
be visible on the right. This isn't usually what you want, though. Usually you want 
your users to be able to control whether a side is hidden or not. To do this, pass the 
SideHolder ObservableObject that holds onto the side you are hiding. Similarly SplitView 
comes with a FractionHolder and LayoutHolder. Under the covers, the SplitView that results 
from the `split` modifier observes all of these holders and redraws itself if they change. 

Here is an example showing how to use the SideHolder with a Button to hide/show the 
Secondary (green) side:

```
struct ContentView: View {
    let hide = SideHolder()         // By default, don't hide any side
    var body: some View {
        VStack(spacing: 0) {
            Button("Toggle Hide") {
                withAnimation {
                    hide.toggle()   // Toggle between hiding nothing and hiding Secondary
                }
            }
            Color.red.split(.Horizontal, hide: hide) { Color.green }
        }
    }
}
```

Note that the `split` modifier accepts `hide` passed as a SplitSide - `.Secondary` or `.Primary` -
or as a SideHolder. Similarly, `layout` can be passed as a SplitLayout - `.Horizontal` or `.Vertical` - 
or as a LayoutHolder. And `fraction` can be passed as a CGFloat or as a FractionHolder.

### Nesting Split Views

The Primary and/or Secondary views can be SplitViews that result from the `split` modifier.
For example:

```
struct ContentView: View {
    var body: some View {
        Color.red.split(.Horizontal) {
            Color.green.split(.Vertical) {
                Color.blue.split(.Horizontal) {
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
            .split(.Horizontal) { Color.green }
            .split(.Vertical) { Color.blue }
    }
}
```


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
    let layout = LayoutHolder.usingUserDefaults(.Horizontal, key: "myLayout")
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

### Custom Splitters

By default the `split` modifier produces a SplitView that uses the default Splitter. You can 
create your own and use it, though. Your custom splitter has to conform to SplitDivider 
protocol, which makes sure your custom splitter can let the SplitView know what its 
`visibleThickness` is. The `visibleThickness` is the size your custom splitter displays 
itself in, and it also defines the `spacing` between the Primary and Secondary views inside 
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

### Invisible Splitters

You might want the views you split to be adjustable using the splitter, but for the splitter 
itself to be invisible. For example, a "normal" sidebar doesn't show a splitter between it 
and the detail view it sits next to. You can do this using the standard Splitter with 
`visibleThickness` set to zero, and passing that as the custom splitter.

```
struct ContentView: View {
    var body: some View {
        Color.red
        .split(
            .Horizontal,
            splitter: { Splitter(.Horizontal, visibleThickness: 0) },
            secondary: { Color.green }
        )
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

I might add a few things but would be very happy to accept pull requests! For example:

* A splitter that adapted to device orientation and form factors somewhat like 
NavigationSplitView does.
* Accept a minimum size for dragging. This doesn't seem important to me as long 
as the splitter has a reasonable `visibleThickness`, but when the splitter is 
invisible, it will be confusing when it's dragged to the edges of the view.
* Do a better job generalizing the default settings so as to be set programmatically.

## History

### Version 1.0

Make layout adjustable. Clean up and formalize the SplitDemo, including the custom splitter and "invisible" splitter. Update the README.

### Version 0.2

Eliminates the use of the clear background and SizePreferenceKeys. (My suspicion is they were needed earlier because GeometryReader otherwise caused bad behavior, but in any case they are not needed now.) Eliminate HSplitView and VSplitView, which were themselves holding onto a SplitView. The layering was both unnecessary and not adding value other than making it explicit what kind of SplitView was being created. I concluded that the same expression was actually clearer and more concise using ViewModifiers. I also added the Example.xcworkspace.

### Version 0.1

Originally posted in [response](https://stackoverflow.com/a/68926261) to https://stackoverflow.com/q/67403140. This version used HSplitView and VSplitView as a means to create the SplitView. It also used SizePreferenceKeys from a GeometryReader on a clear background to set the size. In nested SplitViews, I found this was causing "Bound preference ... tried to update multiple times per frame" to happen intermittently depending on the view arrangement.

