import os
import sys
import argparse

def run_cmd_pretty(cmd):
    print("Running:", cmd)
    result_code = os.system(cmd)
    print("Return code:", result_code, end='\n\n')
    if result_code != 0:
        sys.exit('COMMAND FAILED')


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
    parser.add_argument('--srcdir', required=True, help='Path to sources root directory')
    parser.add_argument('--builddir', required=True, help='Path to build directory from where image will be built')
    parser.add_argument('--lang', required=True, help='Language of build, e.g.: en_US')
    args = parser.parse_args()

    image_name = "neolibrios.img"
    # memorize the source codes dir - its' the directory we started from
    sources_dir = args.srcdir

    # now we are in build directory
    os.chdir(args.builddir)

    img_files = {
        "MACROS.INC": os.path.join(sources_dir, "programs/macros.inc"),
        "STRUCT.INC": os.path.join(sources_dir, "programs/struct.inc"),
        "HOME.PNG": os.path.join(sources_dir, "data/common/wallpapers/T_Home_3.png"),
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
        # "SETTINGS/CEDIT.INI": os.path.join(sources_dir, "programs/develop/cedit/CEDIT.INI"),
        "SETTINGS/ICON.INI": os.path.join(sources_dir, f"data/{args.lang}/settings/icon.ini"),
        "SETTINGS/KEYMAP.KEY": os.path.join(sources_dir, "programs/system/taskbar/KEYMAP.KEY"),
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
        "@ICON": "programs/system/icon_new/icon",
        "@MENU": "programs/system/menu/menu",
        "@RESHARE": "programs/system/reshare/reshare",
        "@TASKBAR": "programs/system/taskbar/taskbar",
        "CALCPLUS": "programs/other/calcplus/calcplus",
        "PROCMAN": "programs/system/procman/procman",
        "DEFAULT2.SKN": "skins/shkvorka/shkvorka.skn",
        "DEFAULT.SKN": "skins/gnome_green/gnome_green.skn",
        "ESKIN": "programs/system/eskin/eskin",
        "LAUNCHER": "programs/system/launcher/launcher",
        "LOADDRV": "programs/system/loaddrv/loaddrv",
        "SETUP": "programs/system/setup/setup",
        "BOARD": "programs/system/board/board",

        "FS/KFAR": "programs/fs/kfar/trunk/kfar",
        "FS/KFAR.INI": os.path.join(sources_dir, f"data/{args.lang if args.lang != "en_US" else "common"}/File Managers/kfar.ini"),

        "DRIVERS/PS2MOUSE.SYS": "drivers/mouse/ps2mouse4d/ps2mouse.sys",

        "LIB/ARCHIVER.OBJ": "programs/fs/kfar/trunk/kfar_arc/kfar_arc.obj",
        "LIB/BOX_LIB.OBJ": "programs/develop/libraries/box_lib/trunk/box_lib.obj",
        "LIB/CNV_PNG.OBJ": "programs/media/zsea/plugins/png/cnv_png.obj",
        "LIB/LIBGFX.OBJ": "programs/develop/libraries/libs-dev/libgfx/libgfx.obj",
        "LIB/LIBIMG.OBJ": "programs/develop/libraries/libs-dev/libimg/libimg.obj",
        "LIB/LIBINI.OBJ": "programs/develop/libraries/libs-dev/libini/libini.obj",
        "LIB/LIBIO.OBJ": "programs/develop/libraries/libs-dev/libio/libio.obj",
        "LIB/PROC_LIB.OBJ": "programs/develop/libraries/proc_lib/proc_lib.obj",
        "LIB/SORT.OBJ": "programs/develop/libraries/sorter/sort.obj",

        "MEDIA/KIV": "programs/media/kiv/kiv",

        "GAMES/PIPES": "programs/games/pipes/pipes",
        "GAMES/TETRIS": "programs/games/tetris/tetris",
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
    for idx, (imgpath, localpath) in enumerate(img_files.items()):
        cmd_copy_file = f'mcopy -moi {image_name} "{localpath}" "::{imgpath}"'
        run_cmd_pretty(cmd_copy_file)


if __name__ == '__main__':
    main()
