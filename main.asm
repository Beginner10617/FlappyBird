.extern _InitWindow
.extern _SetTargetFPS
.extern _WindowShouldClose
.extern _BeginDrawing
.extern _ClearBackground
.extern _EndDrawing
.extern _CloseWindow
.extern _DrawRectangle
.extern _DrawTriangle

.text
.p2align 2
.globl _main
_main:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  sub sp, sp, #16

  mov x0, #800
  mov x1, #450
  adrp x2, TITLE@PAGE
  add x2, x2, TITLE@PAGEOFF

  bl _InitWindow

  mov x0, #60
  bl _SetTargetFPS
_gameloop:
  bl _WindowShouldClose
  cbnz x0, _end
  
  bl _BeginDrawing

  mov w0, #0xff000000
  bl _ClearBackground

  mov x0, #0
  mov x1, #0
  mov x2, #400
  mov x3, #200
  mov w4, #0xff0000ff // RED COLORED FLAPPY BIRD WALLS
  bl _DrawRectangle

  bl _EndDrawing

  b _gameloop
_end:
  bl _CloseWindow
  mov w0, #0
  add sp, sp, #16
  ldp x29, x30, [sp], #16
  ret 
.data 
TITLE:
  .asciz "Space Shooter"
