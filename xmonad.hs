import XMonad hiding ( (|||) )
import XMonad.Layout.LayoutCombinators (JumpToLayout(..), (|||))
import XMonad.Config.Desktop
import Data.Monoid
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- system
import System.IO (hPutStrLn)

-- util
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)

-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (avoidStruts, docksStartupHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog, doFullFloat, doCenterFloat, doRectFloat)
import XMonad.Hooks.Place (placeHook, withGaps, smart)

-- actions
import XMonad.Actions.CopyWindow

-- layout
import XMonad.Layout.NoBorders 
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ResizableTile

myTerminal      = "kitty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth   = 2

myNormalBorderColor  = "#4D4D4D"
myFocusedBorderColor = "#BD93F9"

-- myWorkspaces    = ["\xf868\x2081", "\xfd2c\x2082", "\xf2ce\x2083", "\xf1bc\x2084", "\xfa9e\x2085", "\xe795\x2086", "\xf667\x2087", "\xf11b\x2088", "\xf085\x2089"]
-- myWorkspaces    = ["1:\xf868", "2:\xfd2c", "3:\xf2ce", "4:\xf1bc", "5:\xfa9e", "6:\xe795", "7:\xf667", "8:\xf11b", "9:\xf085"]
myWorkspaces    = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myModMask       = mod4Mask

-- myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
--     -- launch a terminal
--     [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

--     -- launch rofi drun
--     , ((modm,               xK_p     ), spawn "rofi -show drun")

--     -- launch rofi clipboard
--     , ((modm,               xK_c     ), spawn "rofi -show clipboard")

--     -- close focused window
--     , ((modm .|. shiftMask, xK_c     ), kill)

--      -- Rotate through the available layout algorithms
--     , ((modm,               xK_space ), sendMessage NextLayout)

--     --  Reset the layouts on the current workspace to default
--     , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

--     -- Resize viewed windows to the correct size
--     , ((modm,               xK_n     ), refresh)

--     -- Move focus to the next window
--     , ((modm,               xK_Tab   ), windows W.focusDown)

--     -- Move focus to the next window
--     , ((modm,               xK_j     ), windows W.focusDown)

--     -- Move focus to the previous window
--     , ((modm,               xK_k     ), windows W.focusUp  )

--     -- Move focus to the master window
--     , ((modm,               xK_m     ), windows W.focusMaster  )

--     -- Swap the focused window and the master window
--     , ((modm,               xK_Return), windows W.swapMaster)

--     -- Swap the focused window with the next window
--     , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

--     -- Swap the focused window with the previous window
--     , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

--     -- Shrink the master area
--     , ((modm,               xK_h     ), sendMessage Shrink)

--     -- Expand the master area
--     , ((modm,               xK_l     ), sendMessage Expand)

--     -- Push window back into tiling
--     , ((modm,               xK_t     ), withFocused $ windows . W.sink)

--     -- Increment the number of windows in the master area
--     , ((modm,               xK_i ), sendMessage (IncMasterN 1))

--     -- Deincrement the number of windows in the master area
--     , ((modm,               xK_d), sendMessage (IncMasterN (-1)))

--     -- Toggle the status bar gap
--     -- Use this binding with avoidStruts from Hooks.ManageDocks.
--     -- See also the statusBar function from Hooks.DynamicLog.
--     --
--     -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

--     -- Quit xmonad
--     , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

--     -- Restart xmonad
--     , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

--     -- Run xmessage with a summary of the default keybindings (useful for beginners)
--     , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
--     ]
--     ++

--     -- mod-[1..9], Switch to workspace N
--     -- mod-shift-[1..9], Move client to workspace N
--     [((m .|. modm, k), windows $ f i)
--         | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
--         , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
--     ++

--     -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
--     -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
--     [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
--         | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
--         , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myKeys =
  [ ("M-" ++ m ++ k, windows $ f i)
      | (i, k) <- zip (myWorkspaces) (map show [1 :: Int ..])
      , (f, m) <- [(W.view, ""), (W.shift, "S-"), (copy, "S-C-")]]
  ++
  [ ("S-C-a", windows copyToAll)  -- copy window to all workspaces
  , ("S-C-z", killAllOtherCopies) -- kill copies of window on other workspaces
  , ("M-a", sendMessage MirrorShrink) -- decrease vertical window size
  , ("M-z", sendMessage MirrorExpand) -- increase vertical window size
  , ("M-s", sendMessage ToggleStruts)
  , ("M-f", sendMessage $ JumpToLayout "Full")
  , ("M-t", sendMessage $ JumpToLayout "Spacing ResizableTall")
  , ("M-g", sendMessage $ JumpToLayout "Spacing Grid")
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
  avoidStruts ( tiled ||| grid ||| monocle )
  where
     -- default tiling algorithm partitions the screen into two panes
     nmaster = 1
     delta = 3/100
     tiled_ratio = 1/2
     tiled_spacing = 10
     tiled = spacing tiled_spacing $ ResizableTall nmaster delta tiled_ratio []

     -- grid
     grid_ratio = 16/9
     grid_spacing = 10
     grid = spacing grid_spacing $ Grid grid_ratio

     -- monocle
     -- monocle = smartBorders (Full)
     monocle = noBorders (Full)

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

-- myEventHook = mempty

-- myLogHook = return ()

myStartupHook = do
  spawnOnce "nitrogen --restore &"
  spawnOnce "picom  &"

main = do
  -- `xmobar -x 0` launches the bar on monitor 0
  xmproc <- spawnPipe "xmobar -x 0 /home/sravan/.xmonad/xmobar.config"
  -- launches xmobar as a dock
  xmonad $ ewmh desktopConfig
    { manageHook         = manageDocks <+> manageHook desktopConfig
    , startupHook        = myStartupHook
    , layoutHook         = myLayout
    , borderWidth        = myBorderWidth
    , terminal           = myTerminal
    , modMask            = myModMask
    , normalBorderColor  = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , logHook            = dynamicLogWithPP xmobarPP
                           { ppOutput = \x -> hPutStrLn xmproc x
                           , ppCurrent = xmobarColor "green" "" . wrap "[" "]" -- current workspace in xmobar
                           , ppVisible = xmobarColor "cyan" ""                 -- visible but not current workspace
                           , ppHidden = xmobarColor "yellow" "" . wrap "+" ""  -- hidden workspaces in xmobar
                           , ppHiddenNoWindows = xmobarColor "white" ""        -- hidden workspaces (no windows)
                           , ppTitle = xmobarColor "purple" "" . shorten 80    -- title of active window in xmobar
                           , ppSep = " | "                                     -- separators in xmobar
                           , ppUrgent = xmobarColor "red" "" . wrap "!" "!"    -- urgent workspace
                           , ppOrder = \(ws:l:t:ex) -> [ws,l,t]
                           }
        -- focusFollowsMouse  = myFocusFollowsMouse,
        -- clickJustFocuses   = myClickJustFocuses,
        -- workspaces         = myWorkspaces,
        -- keys               = myKeys,
        -- mouseBindings      = myMouseBindings,
        -- handleEventHook    = myEventHook,
    } `additionalKeysP` myKeys

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
