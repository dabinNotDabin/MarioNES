# MarioNES

Quick Setup and Run

1. Connect 40pin Ribbon Cable from Pi to a Breakout Board along with a NES controller.
2. Connect microUSB Power Cable to the Pi
3. Start J-Link GDB Server in its own terminal window
      $ JLinkGDBServer
4. Open a second terminal window and change into the directory with the makefile then build the project
      $ cd /your/dir/
      $ make all
5. Start GDB in the same folder as the makefile (after building project)
      $ arm-none-eabi-gdb build/output.elf

For the following steps, (gdb) is not part of the command but an indicator that you should have gdb running while executing these commands. If you do not, then restart the JLink Device, replug the Pi and retry.
 
6. Connect GDB to J-Link GDB Server
      $ (gdb) target remote localhost:2331 
      The previous line may vary depending on your system
7. Load the program into the Raspberry Pi and run it.
      $ (gdb) load
      $ (gdb) set $pc = start
      $ (gdb) continue
      
      
Note that I am currently working on compatibility with Raspbian, an operating system for the Raspberry Pi.
  This has been difficult mostly due to differences in frame buffer properties between the Raspberry Pi's default and the standard for     
  Raspbian. The Raspberry Pi uses 16 bpp colour information by default and the program was written to function this way whereas the
  Raspbian works in 32 bpp. I am not currently well versed enough nor do I have the time to develop a windowed application but I will
  eventually come up with something that people can check out without a JTAG kit and a breakout board.




# Non-GUI Mario Builder

  Currently, if you do have access to this sort of setup, it is a farily straightforward venture to modify and create levels. You'll notice that there are five (5) files in the source folder that are named similarily to ScreenXStatic--Grid.s.

  These are the level grids and correspond to the levels avaliable in game. The numbers in the 2D arrays can be changed to recreate the level where the only restriction is the types of tiles the game currently supports and possibly the CPU speed when too large an amount of tiles requiring animation are instantiated.
  
  The codes for the tile types are as follows.
  
   * 1   -   Floor Block
   * 2   -   Goomba
   * 4   -   Pipe Top Left
   * 5   -   Pipe Top Right
   * 6   -   Pipe Shaft Left
   * 7   -   Pipe Shaft Right
   * 8   -   Cannon Top
   * 9   -   Cannon Bottom
   * 12  -   Breakable Brick Block
   * 16  -   Question Block
   * 20  -   Coin
   * 25  -   Invisible 'Game-Win-Trigger' Tile -- Collision triggers win animation.
    
    
    
# Bugs
   * Mario stands awkwardly after jumping and landing partially on, partially off of a block of some kind
   * Mario is snapped to grid inappropriately when landing after jumping
   * Mario's movement off of the top of the screen is not handled and can cause crashes or extremely unpredictable behavior
   * Mario doesn't always win in sprite collisions when it is obvious that he should.
   * Question Blocks pop out coins when collided with from below and if there is another collidable tile too close above the question         block, it will produce erroneous outcomes.
   * When a cannon top is immediately horizontally adjacent to a floor, wood, or question block and Mario stands on that block, the           game can crash
    
