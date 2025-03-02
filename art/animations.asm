;---------------------------------------------------
; Animation sequence:
; v1 - if no branches
; v2 - if the branch under (due to change of sides) the lumberjack and none above 
;
; - (last position)
; - phase 2 page 1
; - phase 2 page 2
; - phase 2 page 3
; - phase 2 page 4
; - phase 3 page 1
; - phase 3 page 2
; - phase 3 page 3
; - phase 3 page 4
; - phase 3 page 5
; - phase 2 page 1
; - phase 1 page 1 (new position)
;
; v3 - if the branch opposite the lumberjack and no branch and none above
;
; - (last position)
; - phase 2 page 5
; - phase 2 page 6
; - phase 2 page 7
; - phase 2 page 8
; - phase 3 page 6
; - phase 3 page 2
; - phase 3 page 3
; - phase 3 page 4
; - phase 3 page 5
; - phase 2 page 1
; - phase 1 page 1 (new position)
;
; v4 - if no branch at the level of the lumberjack and branch above (kill)
; v5 - if the branch under (due to change of sides) the lumberjack and branch above (kill)
;
; - (last position)
; - phase 2 page 1
; - phase 2 page 2
; - phase 2 page 3
; - phase 2 page 4
; - phase 3 page 1
; - phase 3 page 11
; - phase 3 page 12
; - phase 3 page 13
; - phase 3 page 14
; - phase 1 page 1 (new position) - killed
;
; v6 - if the branch opposite the lumberjack and branch above (kill)
;
; - (last position)
; - phase 2 page 5
; - phase 2 page 6
; - phase 2 page 7
; - phase 2 page 8
; - phase 3 page 6
; - phase 3 page 11
; - phase 3 page 12
; - phase 3 page 13
; - phase 3 page 14
; - phase 1 page 1 (new position) - killed
;
; v7 - if no branch at the level of the lumberjack and branch above on the other side
; v8 - if the branch under (due to change of sides) the lumberjack and branch above on the other side
;
; - (last position)
; - phase 2 page 1
; - phase 2 page 2
; - phase 2 page 3
; - phase 2 page 4
; - phase 3 page 1
; - phase 3 page 7
; - phase 3 page 8
; - phase 3 page 9
; - phase 3 page 10
; - phase 2 page 5
; - phase 1 page 2 (new position)
;
; v9 - if the branch opposite the lumberjack and branch above on the other side
;
; - (last position)
; - phase 2 page 5
; - phase 2 page 6
; - phase 2 page 7
; - phase 2 page 8
; - phase 3 page 6
; - phase 3 page 7
; - phase 3 page 8
; - phase 3 page 9
; - phase 3 page 10
; - phase 2 page 5
; - phase 1 page 2 (new position)
;
;--------------------------------------------------
.proc AnimationR1
;--------------------------------------------------
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    mwa #gamescreen_r_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p2 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p3 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p4 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_r_ph3p1 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p2 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p3 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p4 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p5 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph1p1 animation_addr
    mva #1 LumberjackDir    ; right side
    rts
.endp
AnimationR2 = AnimationR1
;--------------------------------------------------
.proc AnimationL1
;--------------------------------------------------
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    mwa #gamescreen_l_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p2 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p3 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p4 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_l_ph3p1 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p2 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p3 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p4 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p5 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph1p1 animation_addr
    mva #2 LumberjackDir    ; left side
    rts
.endp
AnimationL2 = AnimationL1
;--------------------------------------------------
.proc AnimationR3
;--------------------------------------------------
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    mwa #gamescreen_r_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p6 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p7 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p8 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_r_ph3p6 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p2 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p3 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p4 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p5 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph1p1 animation_addr
    mva #1 LumberjackDir    ; right side
    rts
.endp
;--------------------------------------------------
.proc AnimationL3
;--------------------------------------------------
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    mwa #gamescreen_l_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p6 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p7 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p8 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_l_ph3p6 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p2 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p3 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p4 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p5 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph1p1 animation_addr
    mva #2 LumberjackDir    ; left side
    rts
.endp
;--------------------------------------------------
.proc AnimationR4
;--------------------------------------------------
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    mwa #gamescreen_r_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p2 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p3 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p4 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_r_ph3p1 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p11 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p12 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p13 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p14 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph1p1 animation_addr
    mva #1 LumberjackDir    ; right side (kill)
    rts
.endp
AnimationR5 = AnimationR4
;--------------------------------------------------
.proc AnimationL4
;--------------------------------------------------
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    mwa #gamescreen_l_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p2 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p3 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p4 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_l_ph3p1 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p11 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p12 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p13 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p14 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph1p1 animation_addr
    mva #2 LumberjackDir    ; left side (kill)
    rts
.endp
AnimationL5 = AnimationL4
;--------------------------------------------------
.proc AnimationR6
;--------------------------------------------------
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    mwa #gamescreen_r_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p6 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p7 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p8 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_r_ph3p6 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p11 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p12 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p13 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p14 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph1p1 animation_addr
    mva #1 LumberjackDir    ; right side (kill)
    rts
.endp
;--------------------------------------------------
.proc AnimationL6
;--------------------------------------------------
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    mwa #gamescreen_l_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p6 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p7 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p8 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_l_ph3p6 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p11 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p12 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p13 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p14 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph1p1 animation_addr
    mva #2 LumberjackDir    ; left side (kill)
    rts
.endp
;--------------------------------------------------
.proc AnimationR7
;--------------------------------------------------
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    mwa #gamescreen_r_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p2 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p3 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p4 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_r_ph3p1 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p7 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p8 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p9 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p10 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph1p2 animation_addr
    mva #1 LumberjackDir    ; right side
    rts
.endp
AnimationR8 = AnimationR7
;--------------------------------------------------
.proc AnimationL7
;--------------------------------------------------
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    mwa #gamescreen_l_ph2p1 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p2 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p3 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p4 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_l_ph3p1 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p7 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p8 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p9 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p10 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph1p2 animation_addr
    mva #2 LumberjackDir    ; left side
    rts
.endp
AnimationL8 = AnimationL7
;--------------------------------------------------
.proc AnimationR9
;--------------------------------------------------
    mva #>font_game_lower_right LowCharsetBase
    mwa #last_line_r lastline_addr
    mwa #gamescreen_r_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p6 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p7 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph2p8 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_r_ph3p6 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p7 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p8 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p9 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph3p10 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_r_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_r_ph1p2 animation_addr
    mva #1 LumberjackDir    ; right side
    rts
.endp
;--------------------------------------------------
.proc AnimationL9
;--------------------------------------------------
    mva #>font_game_lower_left LowCharsetBase
    mwa #last_line_l lastline_addr
    mwa #gamescreen_l_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p6 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p7 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph2p8 animation_addr
    jsr RestoreRedBar
    WaitForSync
    mwa #gamescreen_l_ph3p6 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p7 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p8 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p9 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph3p10 animation_addr
    WaitForSync
    jsr branches_go_down
    mwa #gamescreen_l_ph2p5 animation_addr
    WaitForSync
    mwa #gamescreen_l_ph1p2 animation_addr
    mva #2 LumberjackDir    ; left side
    rts
.endp
;--------------------------------------------------
