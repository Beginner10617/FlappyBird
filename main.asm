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
.extern _TextFormat
.extern _IsKeyDown
.extern _printf
.extern _rand

.text
.p2align 2
.globl _main
_main:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  sub sp, sp, #1056 ; allocation for local vars

  mov x0, #800
  mov x1, #450
  adrp x2, TITLE@PAGE
  add x2, x2, TITLE@PAGEOFF

  bl _InitWindow

  mov x0, #60
  bl _SetTargetFPS

  mov x0, #395
  mov x1, #220
  
  str x0, [x29, #-88] ; x posn
  str x1, [x29, #-8]; y posn
  
  mov x0, #0 ; UP?
  mov x1, #1 ; gravity
  mov x2, #0 ; speed
  str x0, [x29, #-16]
  str x1, [x29, #-24]
  str x2, [x29, #-56]

  mov x0, #0; score
  mov x1, #0; game over?
  mov x2, #0; score timer
  str x0, [x29, #-32]
  str x1, [x29, #-40]
  str x2, [x29, #-72]

  mov x1, #0
  ; 6 BLOCKS 
  mov x0, #0
  str x0, [x29, #-48] 
  str x1, [x29, #-152]
  mov x0, #160
  str x0, [x29, #-64]  
  str x1, [x29, #-168]
  mov x0, #320
  str x0, [x29, #-80]  
  str x1, [x29, #-184]
  mov x0, #480
  str x0, [x29, #-96]  
  str x1, [x29, #-200]
  mov x0, #640
  str x0, [x29, #-112]  
  str x1, [x29, #-216]
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

  ; scoring
  ldr x0, [x29, #-32]
  ldr x1, [x29, #-72]
  add x1, x1, #1
  str x1, [x29, #-72]
  cmp x1, #120
  b.lt _skipscoring
  mov x1, #0
  str x1, [x29, #-72]
  ldr x1, [x29, #-40]
  cbnz x1, _skipscoring
  add x0, x0, #1
  str x0, [x29, #-32]

_skipscoring:
  
  ldr x1, [x29, #-144]
  cbnz x1, _alreadyactive
  ldr x0, [x29, #-136]
  add x0,x0, #1
  str x0, [x29, #-136]
  cmp x0, #120
  b.lt _alreadyactive
  mov x0, #1
  str x0, [x29, #-144]


_alreadyactive:
  // Input
  mov x0, #32; #KEY_SPACE
  bl _IsKeyDown
  str x0, [x29, #-16]

  // Update

  ldr x0, [x29, #-40]
  cmp x0, 0
  b.gt _render

  ldr x1, [x29, #-144]
  cmp x1, #0
  b.eq _afterCollsionCheck

  // collision check
  mov x1, #0
  mov x8, #450
  ldr x6, [x29, #-88]
  ldr x7, [x29, #-8]; y posn
  sub x19, x29, #32
  sub x20, x29, #136
_collisionCheck:
  add x1, x1, #1
  cmp x1, #7

  sub x19, x19, #16
  sub x20, x20, #16

  b.ge _afterCollsionCheck
  
  ldr x2, [x19]
  ldr x4, [x20]
  cbz x4, _collisionCheck
  add x3, x2, #20
  cmp x6, x3
  b.gt _collisionCheck
  add x9, x6, #20
  cmp x9, x2
  b.lt _collisionCheck
  ; BLOCKS:
  ; x - x2, x3
  ; y - x4, x5
  add x10, x7, #20
  sub x4, x8, x4
  sub x5, x4, #100
  cmp x10, x4
  b.gt _gameover
  cmp x7, x5
  b.lt _gameover


  b _collisionCheck


_afterCollsionCheck:
  mov x1, #0
  ldr x0, [x29, #-8] ; posn
  ldr x2, [x29, #-16]; up?
  ldr x3, [x29, #-56]; speed
  ldr x4, [x29, #-24]; gravity
  cmp x2, #0
  b.eq _applyPhy
  mov x4, #-1
  mov x3, #-5
  
_applyPhy:
  add x0, x0, x3; posn = posn + speed
  add x3, x3, x4; speed= speed+ acc
  str x3, [x29, #-56]
  cmp x3, #5
  b.lt _speedinlimit
  mov x3, #5
  str x3, [x29, #-56]
_speedinlimit:
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



  ; 6 BLOCKS 
  sub x19, x29, #32
  sub x20, x29, #136
  mov x21, #0
  ldr x23, [x29, #-144]
_blockupdate:
  add x21, x21, #1
  cmp x21, #7
  b.ge _render
  sub x19, x19, #16
  sub x20, x20, #16

  ldr x0, [x19]
  sub x0, x0, #1
  str x0, [x19] ; x posn of the block
  cmp x0, #-80
  b.gt _blockupdate
  add x0, x0, #960 
  str x0, [x19] ; x posn of the block

  cbz x23, _blockupdate
  mov x22, #349
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
  ldr x0, [x29, #-88]
  ldr x1, [x29, #-8]
  adrp x2, WIDTH@PAGE
  add x2, x2, WIDTH@PAGEOFF
  ldr x2, [x2]
  mov x3, x2
  mov w4, #0xff0000ff // RED COLORED FLAPPY BIRD, WHITE COLORED WALLS
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
  sub x1, x1, #550
  mov x2, #20
  mov x3, #450
  mov w4, #0xffffffff
  bl _DrawRectangle

_zeroheight:
  sub x19, x19, #8
  sub x20, x20, #8
  sub x21, x21, #1
  cbnz x21, _blockdrawloop


  adrp x0, SCORE@PAGE
  add x0, x0, SCORE@PAGEOFF
  ldr x1, [x29, #-32]
  str x1, [sp, #0]
  bl _TextFormat
  
  mov x1, #0
  mov x2, #0
  mov x3, #40
  mov w4, #0xff0000ff
  bl _DrawText


  ldr x0, [x29, #-40]
  cbnz x0, _gameover

_notactiveloop:
  bl _EndDrawing

  b _gameloop

_end:
  bl _CloseWindow
  mov w0, #0
  add sp, sp, #1056 ; deallocation
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
  b _notactiveloop

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
SCORE:
  .asciz "SCORE: %d"
