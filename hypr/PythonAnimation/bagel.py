import math
import time
import sys

def render_bagel():
    t = time.time() * 30
    A = t * 0.04
    B = t * 0.02
    
    b = ['\u00A0'] * 1760  
    z = [0.0] * 1760
    
    theta = 0.0
    while theta < 6.28:
        phi = 0.0
        while phi < 6.28:
            sin_phi = math.sin(phi)
            cos_theta = math.cos(theta)
            sin_A = math.sin(A)
            sin_theta = math.sin(theta)
            cos_A = math.cos(A)
            
            circle_x = cos_theta + 2
            D = 1 / (sin_phi * circle_x * sin_A + sin_theta * cos_A + 5)
            
            cos_phi = math.cos(phi)
            cos_B = math.cos(B)
            sin_B = math.sin(B)
            
            t_var = sin_phi * circle_x * cos_A - sin_theta * sin_A
            
            x = int(40 + 30 * D * (cos_phi * circle_x * cos_B - t_var * sin_B))
            y = int(12 + 15 * D * (cos_phi * circle_x * sin_B + t_var * cos_B))
            
            N = int(8 * ((sin_theta * sin_A - sin_phi * cos_theta * cos_A) * cos_B - sin_phi * cos_theta * sin_A - sin_theta * cos_A - cos_phi * cos_theta * sin_B))
            
            idx = x + 80 * y
            
            if 0 <= y < 22 and 0 <= x < 80 and D > z[idx]:
                z[idx] = D
                b[idx] = ".,-~:;=!*#$@"[max(0, min(11, N))]
            phi += 0.02
        theta += 0.07
        
    output = ""
    for row in range(22):
        output += ''.join(b[row * 80 : (row + 1) * 80]) + '\n'
        
    print(output.rstrip(), flush=True)

if __name__ == "__main__":
    render_bagel()
