import os
import argparse

def run_cmd_pretty(cmd):
    print("Running:", cmd)
    result_code = os.system(cmd)
    print("Return code:", result_code, end='\n\n')


# to test, in the root of the project run
# python3 make_image.py --srctree . --builddir build_en --targetimg neolibrios.img

def main():
    parser = argparse.ArgumentParser(description='Process args')

    parser.add_argument('--srctree', required=True, help='Path to source tree')
    parser.add_argument('--builddir', required=True, help='Path to build dir')
    parser.add_argument('--targetimg', required=True, help='Target image path')


    args = parser.parse_args()

    # print(f"Source tree: {args.srctree}")
    # print(f"Build directory: {args.builddir}")
    # print(f"Target image: {args.targetimg}")
    
    # create empty 1.44M file
    run_cmd_pretty(f"dd status=none if=/dev/zero of={args.targetimg} count=2880 bs=512")

    # format it as a standard 1.44M floppy
    run_cmd_pretty(f"mformat -f 1440 -i {args.targetimg} ::")

    # copy fat12 bootloader
    run_cmd_pretty(f"dd status=none if={os.path.join(args.builddir, "kernel/bootloader/boot_fat12.bin")} of={args.targetimg} count=1 bs=512 conv=notrunc")




    # try copy kernel
    run_cmd_pretty(f'mcopy -moi {args.targetimg} "{os.path.join(args.builddir, "kernel/kernel.mnt")}" "::{"KERNEL.MNT"}"')


    # TODO

if __name__ == '__main__':
    main()
