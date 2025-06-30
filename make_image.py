import os
import argparse

def run_cmd_pretty(cmd):
    print("Running:", cmd)
    result_code = os.system(cmd)
    print("Return code:", result_code, end='\n\n')


def get_dirs_from_paths(path_list):
    dir_paths = set()
    for key in path_list:
        parts = key.split('/')
        current_path = ''
        for part in parts[:-1]:  # Skip the last part (filename)
            current_path = os.path.join(current_path, part) if current_path else part
            dir_paths.add(current_path)
    # Convert to sorted list before returning
    return sorted(dir_paths)


def main():
    parser = argparse.ArgumentParser(description='Process args')
    parser.add_argument('--builddir', required=True, help='Path to build directory from where image will be built')
    parser.add_argument('--lang', required=True, help='Language of build, e.g.: en_US')
    args = parser.parse_args()

    image_name = "neolibrios.img"
    # memorize the source codes dir - its' the directory we started from
    sources_dir = os.getcwd()

    # now we are in build directory
    os.chdir(args.builddir)

    img_files = {
        "MACROS.INC": os.path.join(sources_dir, "programs/macros.inc"),
        "STRUCT.INC": os.path.join(sources_dir, "programs/struct.inc"),
        "HOME.PNG": os.path.join(sources_dir, "data/common/wallpapers/T_Home.png"),
        "ICONS32.PNG": os.path.join(sources_dir, "data/common/icons32.png"),
        "ICONS16.PNG": os.path.join(sources_dir, "data/common/icons16.png"),
        "LANG.INC": os.path.join(sources_dir, f"data/{args.lang}/lang.inc"),
        # "INDEX.HTM": os.path.join(sources_dir, "data/common/index_htm"),
        # "FONTS/TAHOMA.KF": os.path.join(sources_dir, "data/common/fonts/tahoma.kf"),
        # "LIB/ICONV.OBJ": os.path.join(sources_dir, "data/common/lib/iconv.obj"),
        # "LIB/KMENU.OBJ": os.path.join(sources_dir, "data/common/lib/kmenu.obj"),
        "NETWORK/FTPC.INI": os.path.join(sources_dir, "programs/network/ftpc/ftpc.ini"),
        "NETWORK/FTPD.INI": os.path.join(sources_dir, "data/common/network/ftpd.ini"),
        "NETWORK/USERS.INI": os.path.join(sources_dir, "data/common/network/users.ini"),
        "SETTINGS/ASSOC.INI": os.path.join(sources_dir, "data/common/settings/assoc.ini"),
        "SETTINGS/AUTORUN.DAT": os.path.join(sources_dir, "data/common/settings/AUTORUN.DAT"),
        "SETTINGS/CEDIT.INI": os.path.join(sources_dir, "programs/develop/cedit/CEDIT.INI"),
        "SETTINGS/ICON.INI": os.path.join(sources_dir, f"data/{args.lang}/settings/icon.ini"),
        "SETTINGS/KEYMAP.KEY": os.path.join(sources_dir, "programs/system/taskbar/trunk/KEYMAP.KEY"),
        "SETTINGS/KOLIBRI.LBL": os.path.join(sources_dir, f"data/{args.lang}/settings/kolibri.lbl"),
        "SETTINGS/LANG.INI": os.path.join(sources_dir, f"data/{args.lang}/settings/lang.ini"),
        "SETTINGS/MENU.DAT": os.path.join(sources_dir, f"data/{args.lang}/settings/menu.dat"),
        "SETTINGS/NETWORK.INI": os.path.join(sources_dir, "data/common/settings/network.ini"),
        "SETTINGS/SYSTEM.INI": os.path.join(sources_dir, "data/common/settings/system.ini"),
        "SETTINGS/TASKBAR.INI": os.path.join(sources_dir, "data/common/settings/taskbar.ini"),
        "SETTINGS/SYSTEM.ENV": os.path.join(sources_dir, "data/common/settings/system.env")
    }

    img_files |= {
        "KERNEL.MNT": "kernel/kernel.mnt",
        "LAUNCHER": "programs/system/launcher/launcher",
        "LOADDRV": "programs/system/loaddrv/loaddrv",
        "SETUP": "programs/system/setup/setup",

        "DRIVERS/PS2MOUSE.SYS": "drivers/mouse/ps2mouse4d/ps2mouse.sys"
        #
    }

    # create empty 1.44M file
    run_cmd_pretty(f"dd status=none if=/dev/zero of={image_name} count=2880 bs=512")

    # format it as a standard 1.44M floppy
    run_cmd_pretty(f"mformat -f 1440 -i {image_name} ::")

    # copy fat12 bootloader
    run_cmd_pretty(f"dd status=none if={"kernel/bootloader/boot_fat12.bin"} of={image_name} count=1 bs=512 conv=notrunc")

    # create neccessary dirs inside the image
    dir_list = get_dirs_from_paths(img_files.keys())
    cmd_create_dirs = ""
    for idx, dir in enumerate(dir_list):
        if idx != 0:
            cmd_create_dirs += " && "
        cmd_create_dirs += f'mmd -i {image_name} "::{dir}"'
    run_cmd_pretty(cmd_create_dirs)

    # copy files to the image
    cmd_copy_files = ""
    for idx, (imgpath, localpath) in enumerate(img_files.items()):
        if idx != 0:
            cmd_copy_files += " && "
        cmd_copy_files += f'mcopy -moi {image_name} "{localpath}" "::{imgpath}"'
    run_cmd_pretty(cmd_copy_files)


if __name__ == '__main__':
    main()
