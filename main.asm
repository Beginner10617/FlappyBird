.extern _InitWindow
.extern _SetTargetFPS
.extern _WindowShouldClose
.extern _BeginDrawing
.extern _ClearBackground
.extern _EndDrawing
.extern _CloseWindow
.extern _DrawRectangle
.extern _DrawTriangle
.extern _DrawText
.extern _IsKeyDown
.extern _printf
.extern _rand

.text
.p2align 2
.globl _main
_main:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  sub sp, sp, #1040 ; allocation for local vars

  mov x0, #800
  mov x1, #450
  adrp x2, TITLE@PAGE
  add x2, x2, TITLE@PAGEOFF

  bl _InitWindow

  mov x0, #60
  bl _SetTargetFPS

  mov x0, #395
  mov x1, #220
  
  str x0, [x29, #0] ; x posn
  str x1, [x29, #-8]; y posn
  
  mov x0, #0 ; UP?
  mov x1, #0 ; DOWN?
  str x0, [x29, #-16]
  str x1, [x29, #-24]

  mov x0, #0; score
  mov x1, #0; game over?
  str x0, [x29, #-32]
  str x1, [x29, #-40]

  mov x1, #0
  ; 11 BLOCKS 
  mov x0, #0
  str x0, [x29, #-48] 
  str x1, [x29, #-152]
  mov x0, #80
  str x0, [x29, #-56]  
  str x1, [x29, #-160]
  mov x0, #160
  str x0, [x29, #-64]  
  str x1, [x29, #-168]
  mov x0, #240
  str x0, [x29, #-72]  
  str x1, [x29, #-176]
  mov x0, #320
  str x0, [x29, #-80]  
  str x1, [x29, #-184]
  mov x0, #400
  str x0, [x29, #-88]  
  str x1, [x29, #-192]
  mov x0, #480
  str x0, [x29, #-96]  
  str x1, [x29, #-200]
  mov x0, #560
  str x0, [x29, #-104]  
  str x1, [x29, #-208]
  mov x0, #640
  str x0, [x29, #-112]  
  str x1, [x29, #-216]
  mov x0, #720
  str x0, [x29, #-120]  
  str x1, [x29, #-224]
  mov x0, #800
  str x0, [x29, #-128] 
  str x1, [x29, #-232]

  mov x0, #0
  str x0, [x29, #-136] ; timer
  mov x0, #0 ; active?
  str x0, [x29, #-144]

_gameloop:
  bl _WindowShouldClose
  cbnz x0, _end
  
  ldr x1, [x29, #-144]
  cbnz x0, _alreadyactive
  ldr x0, [x29, #-136]
  add x0,x0, #1
  str x0, [x29, #-136]
  cmp x0, #120
  b.lt _alreadyactive
  mov x0, #1
  str x0, [x29, #-144]


_alreadyactive:
  // Input
  mov x0, #265; #KEY_UP
  bl _IsKeyDown
  str x0, [x29, #-16]

  mov x0, #264; #KEY_DOWN
  bl _IsKeyDown
  str x0, [x29, #-24]

  // Update
  ldr x0, [x29, #-40]
  cmp x0, 0
  b.gt _render
  mov x1, #0
  ldr x0, [x29, #-8]
  ldr x2, [x29, #-16]
  ldr x3, [x29, #-24]
  cmp x2, #0
  b.eq _checkdown
  sub x1, x1, #5
_checkdown:
  cmp x3, #0
  b.eq _applyPhy
  add x1, x1, #5

_applyPhy:
  add x0, x0, x1; posn = posn + step
  cmp x0, #430
  b.lt _checkupper
  mov x0, #430
_checkupper:
  cmp x0, #0
  b.gt _updateposn
  mov x0, #0
_updateposn:
  str x0, [x29, #-8]
  mov x1, #0

  adrp x1, SPEED@PAGE
  add x1, x1, SPEED@PAGEOFF
  ldr x1, [x1]



  ; 11 BLOCKS 
  sub x19, x29, #40
  sub x20, x29, #144
  mov x21, #0
  ldr x23, [x29, #-144]
_blockupdate:
  add x21, x21, #1
  cmp x21, #11
  b.ge _render
  sub x19, x19, #8
  sub x20, x20, #8

  ldr x0, [x19]
  sub x0, x0, #1
  str x0, [x19] ; x posn of the block
  cmp x0, #-20
  b.gt _blockupdate
  add x0, x0, #880 
  str x0, [x19] ; x posn of the block

  cbz x23, _blockupdate
  mov x22, #419
  bl _rand
  udiv x5, x0, x22
  msub x0, x5, x22, x0
  add x0, x0, #1
  str x0, [x20] ; height of the block


_render:
  bl _BeginDrawing

  mov w0, #0xff000000
  bl _ClearBackground

  // Drawing rectangle
  ldr x0, [x29, #0]
  ldr x1, [x29, #-8]
  adrp x2, WIDTH@PAGE
  add x2, x2, WIDTH@PAGEOFF
  ldr x2, [x2]
  mov x3, x2
  mov w4, #0xff0000ff // RED COLORED FLAPPY BIRD WALLS
  bl _DrawRectangle


  ldr x0, [x29, #-144]
  cmp x0, #0

  b.eq _notactiveloop

  sub x19, x29, #48
  sub x20, x29, #152
  mov x21, #11
  mov x22, #450
_blockdrawloop:
  ldr x0, [x19]
  ldr x1, [x20]
  sub x1, x22, x1
  mov x24, x1
  mov x2, #20
  mov x3, #450
  mov w4, #0xffffffff
  bl _DrawRectangle

  ldr x0, [x20]
  cbz x0, _zeroheight

  ldr x0, [x19]
  mov x1, x24
  sub x1, x1, #480
  mov x2, #20
  mov x3, #450
  mov w4, #0xffffffff
  bl _DrawRectangle

_zeroheight:
  sub x19, x19, #8
  sub x20, x20, #8
  sub x21, x21, #1
  cbnz x21, _blockdrawloop

_notactiveloop:
  bl _EndDrawing

  ldr x0, [x29, #-40]
  cmp x0, #0
  b.eq _gameloop
  b _gameover

_end:
  bl _CloseWindow
  mov w0, #0
  add sp, sp, #1040 ; deallocation
  ldp x29, x30, [sp], #16
  ret 

_gameover:
  adrp x0, GAME_OVER@PAGE
  add x0, x0, GAME_OVER@PAGEOFF
  mov x1, #190
  mov x2, #200
  mov x3, #70
  mov w4, #0xff0000ff
  bl _DrawText
  mov x0, #1
  str x0, [x29, #-40]
  b _gameloop

.data 
TITLE:
  .asciz "Flappy Bird"
WIDTH:
  .quad 20
SPEED:
  .quad 2
GAME_OVER:
  .asciz "GAME OVER"
DEBUG:
  .asciz "HERE\n"
