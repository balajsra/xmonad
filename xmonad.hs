import XMonad hiding ( (|||) )
import XMonad.Layout.LayoutCombinators (JumpToLayout(..), (|||))
import XMonad.Config.Desktop
import Data.Monoid
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- util
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)

-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (docks, avoidStruts, docksStartupHook, manageDocks, ToggleStruts(..), SetStruts(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog, doFullFloat, doCenterFloat, doRectFloat)
import XMonad.Hooks.Place (placeHook, withGaps, smart)

-- actions
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS

-- layout
import XMonad.Layout.NoBorders 
import XMonad.Layout.Spacing (spacingRaw, Border(Border))
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ResizableTile

myTerminal      = "alacritty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth   = 2

myNormalBorderColor  = "#4D4D4D"
myFocusedBorderColor = "#BD93F9"

myWorkspaces    = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myModMask       = mod4Mask

myKeys =
  [
  -- dwm-like add window to a specific workspace
    ("M-" ++ m ++ k, windows $ f i)
      | (i, k) <- zip (myWorkspaces) (map show [1 :: Int ..])
      , (f, m) <- [(W.view, ""), (W.shift, "S-"), (copy, "S-C-")]
  ]
  ++
  [
  -- dwm-like add/remove window to/from all workspaces
    ("M-C-S-a", windows copyToAll)  -- copy window to all workspaces
  , ("M-C-S-z", killAllOtherCopies) -- kill copies of window on other workspaces

  -- modify tiled window size
  , ("M-a", sendMessage MirrorShrink) -- decrease vertical window size
  , ("M-z", sendMessage MirrorExpand) -- increase vertical window size

  -- toggle struts for xmobar
  , ("M-s", sendMessage ToggleStruts)

  -- full mode w/ all gaps
  , ("M-f", sequence_
      [ sendMessage $ JumpToLayout "Full"
      , sendMessage $ SetStruts [minBound .. maxBound] []])
  -- full mode w/ all gaps and flatten floating windows
  , ("M-S-f", sequence_
      [ withFocused $ windows . W.sink
      , refresh
      , sendMessage $ JumpToLayout "Full"
      , sendMessage $ SetStruts [minBound .. maxBound] []])
  -- full mode w/ no gaps and flatten floating windows
  , ("M-C-S-f", sequence_
      [ withFocused $ windows . W.sink
      , refresh
      , sendMessage $ JumpToLayout "Full"
      , sendMessage $ SetStruts [] [minBound .. maxBound]])
  -- tall mode w/ all gaps
  , ("M-t", sequence_
      [ sendMessage $ JumpToLayout "Spacing ResizableTall"
      , sendMessage $ SetStruts [minBound .. maxBound] []])
  -- tall mode w/ all gaps and flatten floating windows
  , ("M-S-t", sequence_
      [ withFocused $ windows . W.sink
      , refresh
      , sendMessage $ JumpToLayout "Spacing ResizableTall"
      , sendMessage $ SetStruts [minBound .. maxBound] []])
  -- grid mode w/ all gaps
  , ("M-g", sequence_
      [ sendMessage $ JumpToLayout "Spacing Grid"
      , sendMessage $ SetStruts [minBound .. maxBound] []])
  -- grid mode w/ all gaps and flatten floating windows
  , ("M-S-g", sequence_
      [ withFocused $ windows . W.sink
      , refresh
      , sendMessage $ JumpToLayout "Spacing Grid"
      , sendMessage $ SetStruts [minBound .. maxBound] []])

  -- cycle & move between screens
  , ("M-,",     prevScreen)
  , ("M-S-,",   shiftPrevScreen)
  , ("M-C-S-,", swapPrevScreen)
  , ("M-.",     nextScreen)
  , ("M-S-.",   shiftNextScreen)
  , ("M-C-S-.", swapNextScreen)

  -- launch rofi
  , ("M-p", spawn "rofi -show combi")
  , ("M-S-p", spawn "/home/sravan/.scripts/control-center.sh --rofi")
  , ("M-c", spawn "rofi -show clipboard")
  , ("M-b", spawn "rofi-rbw")

  -- volume control
  , ("<XF86AudioRaiseVolume>", spawn "/home/sravan/.scripts/pactl.sh --raise") -- increase volume
  , ("<XF86AudioLowerVolume>", spawn "/home/sravan/.scripts/pactl.sh --lower") -- decrease volume
  , ("<XF86AudioMute>",        spawn "/home/sravan/.scripts/pactl.sh --mute")  -- mute volume
  , ("M-v",                    spawn "/home/sravan/.scripts/pactl.sh --rofi")  -- rofi menu

  -- media control
  , ("<XF86AudioPlay>", spawn "/home/sravan/.scripts/playerctl.sh --play-pause")  -- play / pause
  , ("M-m",             spawn "/home/sravan/.scripts/playerctl.sh --rofi")        -- rofi menu

  -- notification control
  , ("M-n",     spawn "/home/sravan/.scripts/dunst.sh --rofi") -- rofi menu

  -- session control
  , ("M-q",   spawn "/home/sravan/.scripts/session.sh --rofi") -- rofi menu
  , ("M-S-q", io (exitWith ExitSuccess))

  -- close focused window
  , ("M-S-c",   kill)          -- regular kill
  , ("M-C-S-c", spawn "xkill") -- force kill

  -- compositor control
  , ("M-<Esc>", spawn "/home/sravan/.scripts/picom.sh --rofi")

  -- screenshot
  , ("<Print>", spawn "flameshot gui")
  ]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

myLayout =
  -- remove borders on floating windows that cover the whole screen
  lessBorders OnlyScreenFloat
  -- avoid struts (status bar)
  $ avoidStruts ( tiled ||| grid ||| monocle )
  where
     -- Gaps around and between windows
     -- Changes only seem to apply if I log out then in again
     -- Dimensions are given as (Border top bottom right left)
     mySpacing = spacingRaw False                -- Only for >1 window
                            -- The bottom edge seems to look narrower than it is
                            (Border 15 15 15 15) -- Size of screen edge gaps
                            True                 -- Enable screen edge gaps
                            (Border 10 10 10 10) -- Size of window gaps
                            True                 -- Enable window gaps

     -- default tiling algorithm partitions the screen into two panes
     nmaster = 1
     delta = 3/100
     tiled_ratio = 1/2
     tiled = mySpacing $ ResizableTall nmaster delta tiled_ratio []

     -- grid
     grid_ratio = 16/9
     grid = mySpacing $ Grid grid_ratio

     -- monocle
     -- monocle = smartBorders (Full)
     monocle = noBorders (Full)

myManageHook = composeAll
    [ className =? "MPlayer"            --> doFloat
    , className =? "Gimp"               --> doFloat
    , resource  =? "desktop_window"     --> doIgnore
    , resource  =? "kdesktop"           --> doIgnore
    , title     =? "Picture in picture" --> doFloat
    , title     =? "Origin"             --> doFloat
    ]

myPlacement = withGaps (16,0,16,0) (smart (0.5,0.5))

myEventHook = ewmhDesktopsEventHook <+> fullscreenEventHook

myStartupHook = return()

main = do
  -- launches polybar
  spawn "/home/sravan/.xmonad/polybar/launch.sh &"

  -- launches xmonad
  xmonad $ docks $ ewmh desktopConfig
    { manageHook         = manageDocks <+> myManageHook <+> placeHook myPlacement <+> manageHook desktopConfig
    , startupHook        = myStartupHook
    , layoutHook         = myLayout
    , borderWidth        = myBorderWidth
    , terminal           = myTerminal
    , modMask            = myModMask
    , normalBorderColor  = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , handleEventHook    = myEventHook
    , focusFollowsMouse  = myFocusFollowsMouse
    , clickJustFocuses   = myClickJustFocuses
    , workspaces         = myWorkspaces
    , mouseBindings      = myMouseBindings
    -- , logHook            = myLogHook
    -- , keys               = myKeys
    }
    `additionalKeysP` myKeys

help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
