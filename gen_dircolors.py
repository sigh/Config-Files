#!/usr/bin/env python3
"""
Generate dircolors configuration for colorizing file listings in terminals.

This script creates a .dircolors file that can be used with GNU dircolors to
customize file and directory colors in ls output and shell completion.

Usage:
    gen_dircolors.py                    # Generate dircolors config (default)
    gen_dircolors.py print              # Generate dircolors config (explicit)
    gen_dircolors.py show               # Show color samples for each category
    gen_dircolors.py preview [dir]      # Preview colors on actual files

Examples:
    python3 gen_dircolors.py > ~/.dircolors
    python3 gen_dircolors.py preview /usr/bin
    eval $(dircolors -b ~/.dircolors)

The generated configuration includes modern file extensions and uses 256-color
terminal codes for better visual distinction between file types.
"""

import sys

KINDS = {
    "archive": [
        ".7z",
        ".Z",
        ".ace",
        ".appimage",
        ".arj",
        ".bz",
        ".bz2",
        ".cpio",
        ".deb",
        ".dmg",
        ".dz",
        ".ear",
        ".flatpak",
        ".gz",
        ".jar",
        ".lz",
        ".lzh",
        ".lzma",
        ".pkg",
        ".rar",
        ".rpm",
        ".rz",
        ".sar",
        ".snap",
        ".tar",
        ".taz",
        ".tbz",
        ".tbz2",
        ".tgz",
        ".tlz",
        ".txz",
        ".tz",
        ".war",
        ".xz",
        ".z",
        ".zip",
        ".zoo",
    ],
    "media": [
        ".aac",
        ".anx",
        ".asf",
        ".au",
        ".av1",
        ".avif",
        ".avi",
        ".axa",
        ".axv",
        ".bmp",
        ".cgm",
        ".dl",
        ".emf",
        ".flac",
        ".flc",
        ".fli",
        ".flv",
        ".gif",
        ".gl",
        ".heic",
        ".heif",
        ".jpeg",
        ".jpg",
        ".m2v",
        ".m4a",
        ".m4v",
        ".mid",
        ".midi",
        ".mka",
        ".mkv",
        ".mng",
        ".mov",
        ".mp3",
        ".mp4",
        ".mp4v",
        ".mpc",
        ".mpeg",
        ".mpg",
        ".nuv",
        ".oga",
        ".ogg",
        ".ogm",
        ".ogv",
        ".ogx",
        ".opus",
        ".pbm",
        ".pcx",
        ".pgm",
        ".png",
        ".ppm",
        ".qt",
        ".ra",
        ".rm",
        ".rmvb",
        ".spx",
        ".svg",
        ".svgz",
        ".tga",
        ".tif",
        ".tiff",
        ".vob",
        ".wav",
        ".webm",
        ".webp",
        ".wmv",
        ".xbm",
        ".xcf",
        ".xpm",
        ".xspf",
        ".xwd",
        ".yuv",
        ".swf",
    ],
    "other": [
        ".aux",
        ".bak",
        ".cache",
        ".git",
        ".lock",
        ".log",
        ".o",
        ".orig",
        ".pid",
        ".pyc",
        ".swp",
        ".tmp",
    ],
    "doc": [
        ".doc",
        ".docx",
        ".epub",
        ".md",
        ".markdown",
        ".odt",
        ".pages",
        ".pdf",
        ".rtf",
        ".tex",
        ".txt",
    ],
    "data": [
        ".conf",
        ".config",
        ".csv",
        ".env",
        ".ini",
        ".json",
        ".jsonl",
        ".ndjson",
        ".toml",
        ".xml",
        ".yaml",
        ".yml",
    ],
    "src": [
        ".c",
        ".cc",
        ".cpp",
        ".dart",
        ".go",
        ".h",
        ".hs",
        ".java",
        ".js",
        ".jsx",
        ".kt",
        ".kts",
        ".php",
        ".pl",
        ".py",
        ".rs",
        ".sh",
        ".swift",
        ".ts",
        ".tsx",
        ".vim",
    ],
    "aux_src": [
        "*_test.cc",
        "*_test.go",
        "*_test.js",
        "*_test.py",
        "*_test.rs",
        "*_test.ts",
        "*.test.js",
        "*.test.ts",
        ".css",
        ".htm",
        ".html",
        ".less",
        ".sass",
        ".scss",
        ".svelte",
        ".vue",
        ".xhtml",
    ],
}

MAPPING = [
    ("RESET", "0"),  # reset to "normal" color
    # directories
    ("DIR", "48;5;189"),
    ("STICKY_OTHER_WRITABLE", "34;48;5;189"),
    ("OTHER_WRITABLE", "31;48;5;189"),
    ("STICKY", "01;34;48;5;189"),
    # Regular file
    ("FILE", "38;5;60"),
    # Symbolic link. (If you set this to 'target' instead of a numerical value,
    # the color is as for the file pointed to.)
    # ('LINK', '36'),
    ("LINK", "target"),
    ("FIFO", "40;33"),  # pipe
    ("BLK", "40;33;01"),  # block device driver
    ("CHR", "40;33;01"),  # character device driver
    ("SOCK", "38;5;243;48;5;227"),  # socket
    ("DOOR", "38;5;243;48;5;227"),  # door
    ("ORPHAN", "40;31"),  # symlink to nonexistent file, or non-stat'able file
    ("SETUID", "37;41"),  # file that is setuid (u+s)
    ("SETGID", "30;43"),  # file that is setgid (g+s)
    ("CAPABILITY", "30;41"),  # file with capability
    # Executable files
    ("EXEC", "31"),
    # Custom file types (defined in TYPES)
    ("archive", "38;5;130"),
    ("media", "38;5;90"),
    ("other", "38;5;245"),
    ("doc", "0"),
    ("data", "38;5;25"),
    ("src", "38;5;28"),
    ("aux_src", "38;5;35"),
]

TERMS = ["xterm-256color", "screen-256color"]


def show():
    """Display color samples for each file type."""
    for kind, code in MAPPING:
        print(f"\x1b[{code}m{kind}\x1b[0m")


def preview(directory):
    """Preview colors on actual files in a directory."""
    import os

    if not os.path.exists(directory):
        print(f"Error: Directory '{directory}' does not exist.")
        return

    # Create mappings for efficient lookup
    color_map = dict(MAPPING)
    ext_to_color = {}

    for kind, color_code in MAPPING:
        if kind in KINDS:
            for ext in KINDS[kind]:
                ext_to_color[ext] = color_code

    def get_file_color(filename):
        """Get the appropriate color for a file based on extension."""
        for ext, color in ext_to_color.items():
            if ext.startswith("*"):
                # Handle patterns like *_test.cc
                if filename.endswith(ext[1:]):  # Remove the *
                    return color
            elif filename.lower().endswith(ext.lower()):
                return color

        return color_map.get("FILE", "0")

    try:
        files = sorted(os.listdir(directory))
        print(f"Directory preview: {os.path.abspath(directory)}")
        print("=" * 60)

        for filename in files:
            file_path = os.path.join(directory, filename)

            color = (
                color_map.get("DIR", "0")
                if os.path.isdir(file_path)
                else get_file_color(filename)
            )

            print(f"  \x1b[{color}m{filename}\x1b[0m")

    except PermissionError:
        print(f"Error: Permission denied accessing '{directory}'")
    except Exception as e:
        print(f"Error: {e}")


def output():
    """Generate dircolors configuration output."""
    for term in TERMS:
        print("TERM", term)

    for kind, code in MAPPING:
        for value in KINDS.get(kind, [kind]):
            print(value, code)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == "preview":
            directory = sys.argv[2] if len(sys.argv) > 2 else "."
            preview(directory)
        elif command == "show":
            show()
        elif command == "print":
            output()
        else:
            print(f"Error: Unknown command '{command}'", file=sys.stderr)
            print(
                "Usage: gen_dircolors.py [print|show|preview [directory]]",
                file=sys.stderr,
            )
            sys.exit(1)
    else:
        output()
