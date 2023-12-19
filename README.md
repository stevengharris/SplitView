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

The Split, HSplit, and VSplit views and associated modifiers let you:

* Create a single view containing two views, arranged in a horizontal (side-by-side) 
or vertical (above-and-below) `layout` separated by a draggable `splitter` for resizing.
* Specify the `fraction` of full width/height for the initial position of the splitter.
* Programmatically `hide` either view and change the `layout`.
* Arbitrarily nest split views.
* Constrain the splitter movement by specifying minimum fractions of the full width/height
for either or both views.
* Drag-to-hide, so when you constrain the fraction on a side, you can hide the side 
when you drag more than halfway beyond the constraint.
* Prioritize either of one the views to maintain its width/height as the containing 
view changes size.
* Easily save the state of `fraction`, `layout`, and `hide` so a split view opens 
in its last state between application restarts.
* Use your own custom `splitter` or the default Splitter.
* Make splitters "invisible" (i.e., zero `visibleThickness`) but still draggable for 
resizing.
* Monitor splitter movement in realtime, providing a simple way to create a custom slider.

## Motivation

NavigationSplitView is fine for a sidebar and for applications that conform to a 
nice master-detail type of model. On the other hand, sometimes you just need two 
views to sit side-by-side or above-and-below each other and to adjust the split 
between them. You also might want to compose split views in ways that make sense 
in your own application context.

## Demo

![SplitView](https://user-images.githubusercontent.com/1020361/219515082-6e657bee-e4e2-4efd-9e78-f5c98aaa3083.mov)

This demo is available in the Demo directory as SplitDemo.xcodeproj. 

## Usage

Install the package.

* To split two views horizontally, use an HSplit view.
* To split two views vertically, use a VSplit view.
* To split two views whose layout can be changed between horizontal and vertical, 
use a Split view.

**Note:** You can also use the `.split`, `.vSplit`, and `.hSplit` view modifiers that come 
with the package to create a Split, VSplit, and HSplit view if that makes more sense to you.
See the discussion in [Style](#style).

Once you have created a Split, HSplit, or VSplit view, you can use view modifiers on them 
to:

* Specify the initial fraction of the overall width/height that the left/top side should occupy.
* Identify a side that can be hidden and unhidden.
* Adjust the style of the default Splitter, including its color and thickness.
* Place constraints on the minimum fraction each side occupies and which side should be
prioritized (i.e., remain fixed in size) as the containing view's size changes.
* Provide a custom splitter.
* Be able to toggle layout between horizontal and vertical. This modifier is only 
available for the Split view, since HSplit and VSplit remain in a horizontal or 
vertical layout by definition.

In its simplest form, the HSplit and VSplit views look like this:

```
HSplit(left: { Color.red }, right: { Color.green })
VSplit(top: { Color.red }, bottom: { Color.green })
```

The HSplit is a horizontal split view, evenly split between red on the left and 
green on the right. The VSplit is a vertical split view, evenly split between red 
on the top and green on the bottom. Both views use a default splitter between them 
that can be dragged to change the red and green view sizes.

If you want to set the the initial position of the splitter, you can use the 
`fraction` modifier. Here it is being used with a VSplit view:

```
VSplit(top: { Color.red }, bottom: { Color.green })
    .fraction(0.25)
```

Now you get a red view above the green view, with the top occupying 
1/4 of the window.

Often you want to hide/show one of the views you split. You can do this by specifying 
the side to hide. Specify the side using a SplitSide. For an HSplit view, you can 
identify the side using `.left` or `.right`. For a VSplit view, you can use `.top` 
or `.bottom`. For a Split view (where the layout can change), use `.primary` or 
`.secondary`. In fact, `.left`, `.top`, and `.primary` are all synonyms and can be 
used interchangably. Similarly, `.right`, `.bottom`, and `.secondary` are synonyms.

Here is an HSplit view that hides the right side when it opens:

```
HSplit(left: { Color.red }, right: { Color.green })
    .fraction(0.25)
    .hide(.right)
```

The green side will be hidden, but you can pull it open using the splitter that will 
be visible on the right. This isn't usually what you want, though. Usually you want 
your users to be able to control whether a side is hidden or not. To do this, pass the 
SideHolder ObservableObject that holds onto the side you are hiding. Similarly the SplitView 
package comes with a FractionHolder and LayoutHolder. Under the covers, the Split view 
observes all of these holders and redraws itself if they change. 

Here is an example showing how to use the SideHolder with a Button to hide/show the 
right (green) side:

```
struct ContentView: View {
    let hide = SideHolder()         // By default, don't hide any side
    var body: some View {
        VStack(spacing: 0) {
            Button("Toggle Hide") {
                withAnimation {
                    hide.toggle()   // Toggle between hiding nothing and hiding right
                }
            }
            HSplit(left: { Color.red }, right: { Color.green })
                .hide(hide)
        }
    }
}
```

Note that the `hide` modifier accepts a SplitSide or a SideHolder. Similarly, `layout` 
can be passed as a SplitLayout - `.horizontal` or `.vertical` - or as a LayoutHolder. 
And `fraction` can be passed as a CGFloat or as a FractionHolder.

The `toggle()` method on `hide` toggles the hide/show state for the `secondary` side 
by default. If you want to toggle the hide/show state for a specific side, then use 
`toggle(.primary)` or `toggle(.secondary)` explicitly. (Note that `.primary`, `.left`, 
and `.top` are synonyms; and `.secondary`, `.right`, and `.bottom` are synonyms.)

### Nesting Split Views

Split views themselves can be split. Here is an example where the 
right side of an HSplit is a VSplit that has an HSplit at the bottom:

```
struct ContentView: View {
    var body: some View {
        HSplit(
            left: { Color.green },
            right: {
                VSplit(
                    top: { Color.red },
                    bottom: {
                        HSplit(
                            left: { Color.blue },
                            right: { Color.yellow }
                        )
                    }
                )
            }
        )
    }
}
```

And here is one where an HSplit contains two VSplits:

```
struct ContentView: View {
    var body: some View {
        HSplit(
            left: { 
                VSplit(top: { Color.red }, bottom: { Color.green })
            },
            right: {
                VSplit(top: { Color.yellow }, bottom: { Color.blue })
            }
        )
    }
}
```

### Using UserDefaults For Split State

The three holders - SideHolder, LayoutHolder, and FractionHolder - all come with a 
static method to return instances that get/set their state from UserDefaults.standard. 
Let's expand the previous example to be able to change the `layout` and `hide` state 
and to get/set their values from UserDefaults. Note that if you want to adjust the 
`layout`, you need to use a Split view, not HSplit or VSplit. We create the Split view 
by specifying the `primary` and `secondary` views. When the SplitLayout held by the
LayoutHolder (`layout`) is `.horizontal`, the `primary` view is on the left side, and 
the `secondary` view is on the right.  When the SplitLayout toggles to `vertical`, the 
`primary` view is on the top, and the `secondary` view is on the bottom.

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
            Split(primary: { Color.red }, secondary: { Color.green })
                .fraction(fraction)
                .layout(layout)
                .hide(hide)
        }
    }
}
```

The first time you open this, the sides will be split 50-50, but as you drag the 
splitter, the `fraction` state is also retained in UserDefaults.standard.
You can change the `layout` and hide/show the green view, and when you next open 
the app, the `fraction`, `hide`, and `layout` will all be restored how you left them.

### Modifying And Constraining The Default Splitter 

You can change the way the default Splitter displays using the `styling` modifier. 
For example, you can change the color, inset, and thickness:

```
HSplit(left: { Color.red }, right: { Color.green })
    .fraction(0.25)
    .styling(color: Color.cyan, inset: 4, visibleThickness: 8)
```

If you prefer the splitter to hide also when you hide a side, you can set `hideSplitter`
to `true` in the `styling` modifier. For example:

```
HSplit(left: { Color.red }, right: { Color.green })
    .styling(hideSplitter: true)
```

Note that if you set `hideSplitter` to `true`, you need to include a means for 
your user to unhide a view once it is hidden, like a hide/show button. That's 
because the splitter itself isn't displayed at all, so you can't just drag it out 
from the side.

By default, the splitter can be dragged across the full width/height of the split 
view. The `constraints` modifier lets you constrain the minimum faction of the 
overall view that the "primary" and/or "secondary" view occupies, so the 
splitter always stays within those constraints. You can do this by specifying 
`minPFraction` and/or `minSFraction`. The `minPFraction` refers to left 
in HSplit and top in VSplit, while `minSFraction` refers to right in HSplit and 
bottom in VSplit:

```
HSplit(left: { Color.red }, right: { Color.green })
    .fraction(0.3)
    .constraints(minPFraction: 0.2, minSFraction: 0.2)
```

### Drag-To-Hide

When you constrain the fraction of the primary or secondary side, you may want the 
side to hide automatically when you drag past the constraint. However, we need to 
trigger this drag-to-hide behavior when you drag "well past" the constraint, because 
otherwise, it's difficult to leave the splitter positioned at the constraint without
hiding it. For this reason, a split view defines "well past" to mean "more than 
halfway past the contraint".

Drag-to-hide can be a nice shortcut to avoid having to press a button to hide a side. 
You can see an example of it in Xcode when you drag the splitter between the editor area 
in the middle and the Inspector on the right beyond the constraint Xcode puts on the 
Inspector width. In Xcode, when you drag-to-hide the splitter between the editor area 
and the Inspector, you cannot drag it back out because the splitter itself is hidden. 
You need a button to invoke the hide/show action, as discussed 
[earlier](#modifying-and-constraining-the-default-splitter). The same is true with 
drag-to-hide using a split view when `hideSplitter` is `true`.

When your cursor moves beyond the halfway point of the constrained side, the split view 
previews what it will look like when the side is hidden. This way, you have a visual indication 
that the side will hide, and you can drag back out to avoid hiding it. If your dragging ends 
when the side is hidden, then it will remain hidden.

Note that when you use drag-to-hide, the splitter may or may not be hidden when the side is 
hidden (depending on whether `hideSplitter` is `true` in SplitStyling). The preview of what the 
split view will look like if you release past the halfway point reflects your choice of setting 
for `hideSplitter`.

To use drag-to-hide, add `dragToHideP` and/or `dragToHideS` to your `constraints` definition.
For example, the following will constrain dragging between 20% and 80% of the width, but 
when the drag gesture ends at or beyond the 90% mark on the right, the secondary side will 
hide. Note also that in this case, the primary side doesn't use drag-to-hide:

```
HSplit(left: { Color.red }, right: { Color.green })
    .constraints(minPFraction: 0.2, minSFraction: 0.2, dragToHideS: true)
```

### Custom Splitters

By default the Split, HSplit, and VSplit views all use the default Splitter view. You can 
create your own and use it, though. Your custom splitter should conform to SplitDivider 
protocol, which makes sure your custom splitter can let the Split view know what its 
`styling` is. The `styling.visibleThickness` is the size your custom splitter displays 
itself in, and it also defines the spacing between the `primary` and `secondary` views inside 
of Split view.

The Split view detects drag events occurring in the splitter. For this reason, you might want 
to use a ZStack with an underlying Color.clear that represents the `styling.invisibleThickness`
if the `styling.visibleThickness` is too small for properly detecting the drag events.

Here is an example custom splitter whose contents is sensitive to the observed `layout` 
and `hide` state:

```
struct CustomSplitter: SplitDivider {
    @ObservedObject var layout: LayoutHolder
    @ObservedObject var hide: SideHolder
    @ObservedObject var styling: SplitStyling
    /// The `hideButton` state tells whether the custom splitter hides the button that normally shows
    /// in the middle. If `styling.previewHide` is true, then we only want to show the button if
    /// `styling.hideSplitter` is also true.
    /// In general, people using a custom splitter need to handle the layout when `previewHide`
    /// is triggered and that layout may depend on whether `hideSplitter` is `true`.
    @State private var hideButton: Bool = false
    let hideRight = Image(systemName: "arrowtriangle.right.square")
    let hideLeft = Image(systemName: "arrowtriangle.left.square")
    let hideDown = Image(systemName: "arrowtriangle.down.square")
    let hideUp = Image(systemName: "arrowtriangle.up.square")
    
    var body: some View {
        if layout.isHorizontal {
            ZStack {
                Color.clear
                    .frame(width: 30)
                    .padding(0)
                if !hideButton {
                    Button(
                        action: { withAnimation { hide.toggle() } },
                        label: {
                            hide.side == nil ? hideRight.imageScale(.large) : hideLeft.imageScale(.large)
                        }
                    )
                    .buttonStyle(.borderless)
                }
            }
            .contentShape(Rectangle())
            .onChange(of: styling.previewHide) { hide in
                hideButton = styling.hideSplitter
            }
        } else {
            ZStack {
                Color.clear
                    .frame(height: 30)
                    .padding(0)
                if !hideButton {
                    Button(
                        action: { withAnimation { hide.toggle() } },
                        label: {
                            hide.side == nil ? hideDown.imageScale(.large) : hideUp.imageScale(.large)
                        }
                    )
                    .buttonStyle(.borderless)
                }
            }
            .contentShape(Rectangle())
            .onChange(of: styling.previewHide) { hide in
                hideButton = styling.hideSplitter
            }
        }
    }}
``` 

You can use the CustomSplitter like this:

```
struct ContentView: View {
    let layout = LayoutHolder()
    let hide = SideHolder()
    let styling = SplitStyling(visibleThickness: 20)
    var body: some View {
        Split(primary: { Color.red }, secondary: { Color.green })
            .layout(layout)
            .hide(hide)
            .splitter { CustomSplitter(layout: layout, hide: hide, styling: styling) }
    }
}
```

If you make a custom splitter that would be generally useful to people, consider filing 
a pull request for an additional Splitter extension in Splitter+Extensions.swift. 
The `line` Splitter is included in the file as an example that is used in the "Sidebars" 
demo. Similarly, the `invisible` Splitter re-uses the `line` splitter by passing a 
`visibleThickness` of zero and is used in the "Invisible splitter" demo.

### Invisible Splitters

You might want the views you split to be adjustable using the splitter, but for the splitter 
itself to be invisible. For example, a "normal" sidebar doesn't show a splitter between itself 
and the detail view it sits next to. You can do this by passing `Splitter.invisible()` as the 
custom splitter.

One thing to watch out for with an invisible splitter is that when a side is hidden, there 
is no visual indication that it can be dragged back out. To prevent this issue, you should 
specify `minPFraction` and `minSFraction` when using `Splitter.invisible()`.

```
struct ContentView: View {
    let hide = SideHolder()
    var body: some View {
        VStack(spacing: 0) {
            Button("Toggle Hide") {
                withAnimation {
                    hide.toggle()   // Toggle between hiding nothing and hiding secondary
                }
            }
            HSplit(left: { Color.red }, right: { Color.green })
                .hide(hide)
                .constraints(minPFraction: 0.2, minSFraction: 0.2)
                .splitter { Splitter.invisible() }
        }
    }
}
```

### Monitoring And Responding To Splitter Movement

You can specify a callback for the split view to execute as you drag the splitter. The 
callback reports the `privateFraction` being tracked; i.e., the fraction of the full 
width/height occupied by the left/top side. Specify the callback using the `onDrag(_:)`
modifier for any of the split views. 

Here is an example of a DemoSlider that uses the `onDrag(_:)` modifier to update 
a Text view showing the percentage each side is occupying.

```
struct DemoSlider: View {
    @State private var privateFraction: CGFloat = 0.5
    var body: some View {
        HSplit(
            left: {
                ZStack {
                    Color.green
                    Text(percentString(for: .left))
                }
            },
            right: {
                ZStack {
                    Color.red
                    Text(percentString(for: .right))
                }
            }
        )
        .onDrag { fraction in privateFraction = fraction }
        .frame(width: 400, height: 30)
    }

    /// Return a string indicating the percentage occupied by `side`
    func percentString(for side: SplitSide) -> String {
        var percent: Int
        if side.isPrimary {
            percent = Int(round(100 * privateFraction))
        } else {
            percent = Int(round(100 * (1 - privateFraction)))
        }
        // Empty string if the side will be too small to show it
        return percent < 10 ? "" : "\(percent)%"
    }
}
```

It looks like this:

![DemoSlider](https://user-images.githubusercontent.com/1020361/231880861-c710dfb8-ada3-41e2-802b-a71d947b867f.mov)

### Prioritizing The Size Of A Side

When you want a sidebar type of arrangement using HSplit views, you often want 
the sidebar to maintain its width as you resize the overall view. You might 
have the same need with a VSplit, too. If you have two sidebars, you may want 
to slide either one while the opposing one stays the same width. You can 
accomplish this by specifying a `priority` side (either `.left`/`.right` or 
`.top`/`.bottom`) in the `constraints` modifier.

Here is an example that has a red left sidebar and green right sidebar surrounding a 
yellow middle view. As you drag either splitter, the other stays fixed. Under the covers, 
the Split view is adjusting the proportion between `primary` and `secondary` to keep the 
splitter in the same place. You will also see that as you resize the window, both 
sidebars maintain their width.

```
struct ContentView: View {
    var body: some View {
        HSplit(
            left: { Color.red },
            right: {
                HSplit(
                    left: { Color.yellow },
                    right: { Color.green }
                )
                .fraction(0.75)
                .constraints(priority: .right)
            }
        )
        .fraction(0.2)
        .constraints(priority: .left)
    }
}
```

Note that in the example above, the two sidebars have the same width, 
which is 0.2 of the overall width, even though the fractions specified for the 
left and right sides are 0.2 and 0.75 respectively. This is because the left side 
of the outer HSplit is 0.2 of the overall width, leaving 0.8 to divide in the inner 
HSplit. The left side of the inner HSplit is 0.75\*0.8 or 0.6 of the overall width, 
leaving the right side of the inner HSplit to be 0.2 of the overall width.

## Implementation

The heart of the implementation here is the Split view. VSplit and HSplit are really 
convenience and clarity wrappers around Split. There is probably not a big need for 
most people to be able to adjust layout dynamically, which is really the only reason 
to use Split directly.

Although ultimately Split has to deal in width and height, the math of adjusting the 
layout is the same whether its `primary` is at the left or top and its `secondary` is 
at the right or bottom.

The main piece of state that changes in Split view is `constrainedFraction`. This is the 
fraction of the overall width/height occupied by the `primary` view. It changes as you 
drag the splitter. When you hide/show, it does not change, because it holds the state 
needed to restore-to when a hidden view is shown again. The Split view monitors changes 
to its size. The size changes when its containing view changes size (e.g., resizing a 
window on the Mac or when nested in another Split view whose splitter is dragged).

The three views, Split, HSplit, and VSplit all support the same modifiers 
to adjust `fraction`, `hide`, `styling`, `constraints`, `onDrag`, and `splitter`. 
The Split view also has a modifier for `layout` (which is also used by HSplit and 
VSplit) and a few convenience modifiers used by HSplit and VSplit.

### Style

After going all-in on a View modifier style to return a single Split-type of view 
for any View it is invoked on, I read an 
[article by John Sundell](https://swiftbysundell.com/articles/swiftui-views-versus-modifiers/) 
that illustrated some of the "problematic" issues associated with view modifiers 
creating different container views. As a result, I reconsidered my approach. 
I'm still using view modifiers extensively, but now they operate on an explicit 
Split, HSplit, or VSplit container, and always return the same type of view they 
modify. I think this makes usage a lot more clear in the end. 

If you prefer the idea of a View modifier to kick off your Split, HSplit, or VSplit 
creation, you can still use:

```
Color.green.hSplit { Color.red }   // Returns an HSplit
Color.green.vSplit { Color.red }   // Returns a VSplit
Color.green.split { Color.red }    // Returns a Split
```

instead of:

```
HSplit(left: { Color.green }, right: { Color.red } )
VSplit(top: { Color.green }, bottom: { Color.red } )
Split(primary: { Color.green }, secondary: { Color.red })
```

## Issues

1. In versions prior to MacOS 14.0 Sonoma, there is what appears to be a harmless
log message when dragging the Splitter to cause a view size to go to zero on 
Mac Catalyst only. The message shows up in the Xcode console as `[API] cannot 
add handler to 3 from 3 - dropping`. This message is not present as of MacOS 14.0 Sonoma.

2. The Splitter's `onHover` entry action used to display the resizing cursors on Mac Catalyst 
and MacOS may occasionally not be triggered when using nested split views. I think this happens 
seldom enough to not be a problem. When it occurs, the cursor doesn't change to 
`resizeLeftRight` or `resizeUpDown` when hovering over a splitter, but the splitter will 
still be draggable.

## Possible Enhancements

I might add a few things but would be very happy to accept pull requests! For example,
a split view that adapted to device orientation and form factors somewhat like 
NavigationSplitView would be useful.

## History

### Version 3.5

* Publish changes to `fraction`, so that setting the value externally changes the split view layout (Issue [29](https://github.com/stevengharris/SplitView/issues/29)).
* Allow use of `toggle(.primary)` or `toggle(.secondary)` as a way to specify the side to hide/show (thanks [Bastiaan Terhorst](https://github.com/bastiaanterhorst)).
* Fix display bug when specifying `minFractionP` and hiding `primary` side (Issue [31](https://github.com/stevengharris/SplitView/issues/31)).
* Remove forced hiding of splitter when hiding a side with `minFractionP` or `minFractionS` specified (Issue [30](https://github.com/stevengharris/SplitView/issues/30)).
* Update README to reflect changes.

### Version 3.4

* Refactor so that Splitter holds SplitStyling, allowing custom splitters to participate properly in drag-to-hide.
* Incompatible change to SplitDivider protocol to expose `styling: SplitStyling` rather than `visibleThickness`. The incompatibility only affects you if you were using a [custom splitter](#custom-splitters).

### Version 3.3

* Support drag-to-hide with a preview of the side being hidden as you drag beyond the 
halfway point of the constrained side. See the [Drag-To-Hide](#drag-to-hide) section.

### Version 3.2

* Display resizing cursors on Mac Catalyst and MacOS when hovering over the splitter.
* Add ability to hide a side when dragging completes at a point beyond the minimum constraints. See the [Drag-To-Hide](#drag-to-hide) section.
* Add ability to hide the splitter when a side is hidden. See the information on `hideSplitter` in the [Modifying And Constraining The Default Splitter](#modifying-and-constraining-the-default-splitter) section.

### Version 3.1

* Add `onDrag` modifier to be able to monitor and respond to splitter movement. See the [Monitoring And Responding To Splitter Movement](#monitoring-and-responding-to-splitter-movement) section.

### Version 3.0

* Incompatible change from Version 2 to change from an extensive set of View modifiers to explicit use of Split, HSplit, and VSplit. Most of the previous version's `split` View modifiers have been removed in this version.
* Modify the DemoApp to use the new Split, HSplit, and VSplit approach. Functionality is unchanged.

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

