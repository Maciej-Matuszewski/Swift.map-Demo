# Swift.map-Demo

In March 2019 I made presentation about debugging in Xcode. In this Repository you ca find transcript of my presentation and demo project.

# Intro

Hi! I'm Maciej and today I'll show you few hints how to make debugging easier in everyday work.

## Who am I?

I'm iOS Engineer at Cookpad. Just to let you know, Cookpad is recipe sharing platform. I'm working on parts of app responsible for communication between users. In my everyday work I'm often working on bugs. In this presentation I'll show you how to investigate and fix various issues without wasting too much time.

## LLDB: What it is and what it give us?

In the war for high-quality code, we have a very powerful ally, Low level debugger. I will not bore you with description what it is, but instead I'll show you how you can use it.

## Basic LLDB commands

But before fun will begin we need to learn two commands. First one is `expression`, this command will allow us to inject code when our app is paused on breakpoint. Second command is an alias that allow us to print object description. Please notice that during my presentation I'll be using shortcuts `e` and `po`.

|Command|Shortcut|Description|
|:---|:---|:---|
|expression|**e**, expr|Evaluating a expression in the current frame.|
|expression --object-description --|**po**|Evaluating a expression and print debug description|

# DEMO

Time for practice. Here is beautiful app that I prepared for this presentation. Main purpose of it is to display feed of images from Unsplash service. As you can notice there is something wrong with it and I can assure you that there is even more issues that you can notice and probably even more that I know about.  

## Expression: Item swap in cell for row

First thing that we will take care of is displaying more than one photo. Of course first place to check if something is wrong with cell is `cellForRow:` method. Oho! The problem is that to item variable is always assigning first object of items table. Fix here is very easy. We need to change assign line and recompile... but do we need to recompile to check if our change is correct?

No, I'll create here breakpoint with action to check if this change will work.

_presentation how to create breakpoint with action_

Expression: `e item = self.items[indexPath.row]`

Please keep in mind that bugs and fixes that I'm showing you can seams trivial but I'm focusing on how you can use LLDB and I'm sure that any of you will find more difficult situations where checking if fix will be working without recompile will be huge time saver.

## Expression: Assign delegate on the go

Now time for second problem with this app. Feed of photos is loading only first page beside that we requesting to load next page when the last cell will be displayed.

So first step to diagnose will be adding breakpoint `willDisplayCell:` method and scroll tableView to check if method is executed. Nothing happened, so we can assume that there is something wrong with delegate. Let's go to the initialisation of tableView. Oh! Delegate is not set. This is next easy fix, but I really don't like to recompile, but unfortunately we can't add here breakpoint with action like in example before because this breakpoint will be never reached in this runtime, so we need to find way to pause app when we have access to all elements that we need. Good place for this will be `refresh` method because we are able to execute this manually and during refresh method we are able to reach `self` property. And here we have console view where we can unleashed power of LLDB. Now we can assign delegate to tableView.

`(lldb) e tableView.delegate = self`

## Expression with condition: Fetch

After we resume app we can notice that finally tableView delegate method has been reached and we can move our breakpoint to check if `fetch` method will be executed. Nah, it is still not working. Condition is incorrect. Since rows are counted from 0 it will be never equal to `items.count`. Fix is to add `-1` in condition, but to prevent recompilation once again we can use here breakpoint with condition.

Condition: `indexPath.row == items.count - 1`

Expression: `e fetch()`

Woohoo! We have second page! Three bugs fixed. Recompilation count still equal to zero!

## Symbolic breakpoint: Set content mode

As you probably already notice aspect ratio of photos is incorrect. Of course we can search for place where this has been set up but imagine that this is huge project with many different UIImageViews in different places. There is faster way to find that line we looking for. We can use symbolic breakpoint.

_presentation how to create symbolic breakpoint_

Symbol: `-[UIView setContentMode:]`

By using commands `up` and `down` we can jump between paused frames  

`(lldb) up`

and again by using breakpoint check if fix is correct

Expression: `e imageView.contentMode = .scaleAspectFill`

## Regex breakpoint: HeartAnimation

Now similar situation to using symbolic breakpoint but we don't know exactly on what symbol we would like to pause. Please take a look on this: on double tap we photo should mark as favourite, likes counter in bottom left corner is working well but on top of cell always is presented dislike animation. I'm not sure what method is responsible for this but we can assume that this will be something like heart animation. To find out where this animation is executed and with which parameters I'll use breakpoint with regex.

`(lldb) breakpoint set -r 'HeartAnimation'`

Now we can check value from parameter

`(lldb) po markAsFavorite`

Again by using `up` command we can find place where this method has been called

`(lldb) up`

## Thread jump: Skip animation

As we can see here the parameter should be `true` instead of false, but we are unable to inject new value to parameter because this parameter is not stored in any variable so instead we could call whole line with new parameter, but we can't allow to display two animations at the same time. So we will skip executing this line with thread jump lldb command

Expression: `thread jump --by 1`

Expression: `e feedItemTableViewCell.showHeartAnimation(isLiking: true)`

## List of breakpoints
Now we only need to delete breakpoint for HeartAnimation to prevent pausing every time this method will be called. But we need to know which breakpoint we want to delete. In this situation very useful will be breakpoint list command.

`(lldb) breakpoint list`

## Remove breakpoint

Our breakpoint that we want to remove is X so we need to execute `breakpoint delete X`

`(lldb) breakpoint delete X`

## Edit constraints on the go

All of this bugs where logic problems, and we fixed them without even single recompile, but how about layout issues? In this app we have problem with X axis of heart in animation. Now we can use Debug view hierarchy.

`Debug view hierarchy` → Select constraint → Copy `⌘ + c`

Example: `(lldb) e ((NSLayoutConstraint *)0x6000023dd0e0).constant = 0`

## Flush

To instantly apply changes we can use flush method.

Expression: `expression -l objc -- (void)[CATransaction flush]`

## Command alias

But you need to admit that this is quite long expression, especially if we would like to use this after every visual change. So I'll add alias for that.

Expression: `command alias flush expression -l objc -- (void)[CATransaction flush]`

Now prototyping with designer siting on your back will be much easier and quicker.

## How to find constraint in code?

When we are happy with our changes it would be good to apply them to real code too. Debug view hierarchy can show us where exactly constraints was added, but to make this available we need to turn on malloc stack.

### Turn on Malloc Stack
`Product` → `Scheme` → `Edit Scheme` (⌘<) → `Run` → `Diagnostics` → ☑️ `Malloc Stack` → `All Allocation and Free History`

And now we can point exact place of creating constraints using backtrace section of object inspector.

`Debug view hierarchy` → Select constraint → `Object inspector` → `Backtrace`

# Outro

Since my time slot end few minutes ago I would like to invite you on my github profile where this project will be available with list of all commands that I used during presentation and few more that I didn't fit. Also I would like to encourage you to check WWDC videos about debugging and visit official website of LLDB. I assure you that you will find a lot of useful knowledge there. Thank you!

# Extras

## LLDB init file
**In Terminal:** _vi ~/.lldbinit_

## Custom debug Description
```swift
extension (...): CustomDebugStringConvertible {
    var debugDescription: String {
        return CUSTOM_DEBUG_DESCRIPTION
    }
}
```
