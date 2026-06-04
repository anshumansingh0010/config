#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import sys
def execute(command):
    return subprocess.run(['bash', '-c',command],capture_output=True,text=True)
def arg(i:int):
    return sys.argv[i]

def getshadernames():
    path=Path.home()/".config/hypr/shaders"
    
    files = list(os.listdir(path))
    shadername=[f.removesuffix(".glsl") for f in files]
    
    return shadername
    

def main():
    shaders=(getshadernames())
    print(shaders)
    if len(sys.argv) > 1 and arg(1) =='toggle':
        if  execute("hyprshade current").stdout:
            execute("hyprshade off")

        else:
            execute("hyprshade on vibrance")
    else:
        
        idx=(shaders.index(execute("hyprshade current").stdout.strip()))+1
        idx=(idx)%len(shaders)
        execute(f"hyprshade on {shaders[idx]}")
if __name__=="__main__":
    main()