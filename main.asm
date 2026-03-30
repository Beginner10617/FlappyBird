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

.text
.p2align 2
.globl _main
_main:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  sub sp, sp, #48 ; allocation for local vars

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
  
  mov x0, #-5 ; speed.y (per frame)
  mov x1, #1 ; gravity (per frame)
  str x0, [x29, #-16]
  str x1, [x20, #-24]

  mov x0, #3; deltaT (num of frames)
  mov x1, #0; counter for deltaT
  str x0, [x29, #-32]
  str x1, [x29, #-40]

_gameloop:
  bl _WindowShouldClose
  cbnz x0, _end
  
  // Update
  ldr x0, [x29, #-32]
  ldr x1, [x29, #-40]
  add x1, x1, #1
  cmp x1, x0
  
  b.lt _render
  
  ldr x0, [x29, #-8]
  ldr x1, [x29, #-16]
  ldr x2, [x20, #-24]
  add x0, x0, x1; posn = posn + speed
  add x1, x1, x2;speed =speed + gravity
  str x0, [x29, #-8]
  str x1, [x29, #-16]
  mov x1, #0

_render:
  str x1, [x29, #-40]; Counter update
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

  bl _EndDrawing

  b _gameloop
_end:
  bl _CloseWindow
  mov w0, #0
  add sp, sp, #48 ; deallocation
  ldp x29, x30, [sp], #16
  ret 


.data 
TITLE:
  .asciz "Flappy Bird"
WIDTH:
  .quad 20
GAME_OVER:
  .asciz "GAME OVER"
