1. Change the paths that GEM5 uses to locate the disk images
<GEM5\_DIRECTORY>/configs/common/SysPaths.py:
```
path = [ ’/dist/m5/system’, ’</path/to/my/disks/and/binaries/folder>’ ]
```

<GEM5\_DIRECTORY>/configs/common/Benchmarkspy:
```
elif buildEnv['TARGET_ISA'] == 'X86':
    return env.get(’LINUX_IMAGE’, disk(’my-image-name.img’))
```

2. Change architecture arguments

3. Run the scripts for init, mid, and final stages
