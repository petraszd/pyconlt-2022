import time
import pygame

from tracer import raytrace, WIN_W, WIN_H

# Init
pygame.display.init()
screen_surface = pygame.display.set_mode(
    size=(WIN_W, WIN_H),
    vsync=1
)

# Ray Trace
screen_arr = pygame.surfarray.array2d(screen_surface)

start_time = time.time()
raytrace(screen_arr)
delta_time = time.time() - start_time
print(f"Generation took {delta_time:.02f}s")

pygame.surfarray.blit_array(screen_surface, screen_arr)

# Loop
is_running = True
while is_running:
    event = pygame.event.wait()
    if event.type == pygame.QUIT:
        is_running = False
    elif event.type == pygame.KEYDOWN:
        if event.key == pygame.K_q:
            is_running = False
        elif event.key == pygame.K_ESCAPE:
            is_running = False
    pygame.display.flip()

# Deinit
pygame.quit()
