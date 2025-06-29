import os
import argparse

def run_cmd_pretty(cmd):
    print("Running:", cmd)
    result_code = os.system(cmd)
    print("Return code:", result_code, end='\n\n')


def main():
    parser = argparse.ArgumentParser(description='Process args')

    parser.add_argument('--builddir', required=True, help='Path to build directory from where image will be built')
    args = parser.parse_args()

    image_name = "neolibrios.img"
    # memorize the source codes dir - its' the directory we started from
    sources_dir = os.getcwd()

    # now we are in build directory
    os.chdir(args.builddir)

    # create empty 1.44M file
    run_cmd_pretty(f"dd status=none if=/dev/zero of={image_name} count=2880 bs=512")

    # format it as a standard 1.44M floppy
    run_cmd_pretty(f"mformat -f 1440 -i {image_name} ::")

    # copy fat12 bootloader
    run_cmd_pretty(f"dd status=none if={"kernel/bootloader/boot_fat12.bin"} of={image_name} count=1 bs=512 conv=notrunc")



    # try copy kernel
    run_cmd_pretty(f'mcopy -moi {image_name} "{"kernel/kernel.mnt"}" "::{"KERNEL.MNT"}"')


    # TODO

if __name__ == '__main__':
    main()
