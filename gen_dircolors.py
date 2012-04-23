#!/usr/bin/python

KINDS = {
    'archive': [
        '.7z', '.Z', '.ace', '.arj', '.bz', '.bz2', '.cpio', '.deb', '.dz',
        '.ear', '.gz', '.jar', '.lz', '.lzh', '.lzma', '.rar', '.rpm', '.rz',
        '.sar', '.tar', '.taz', '.tbz', '.tbz2', '.tgz', '.tlz', '.txz', '.tz',
        '.war', '.xz', '.z', '.zip', '.zoo',
    ],
    'media': [
        '.aac', '.anx', '.asf', '.au', '.avi', '.axa', '.axv', '.bmp', '.cgm',
        '.dl', '.emf', '.flac', '.flc', '.fli', '.flv', '.gif', '.gl', '.jpeg',
        '.jpg', '.m2v', '.m4v', '.mid', '.midi', '.mka', '.mkv', '.mng', '.mov',
        '.mp3', '.mp4', '.mp4v', '.mpc', '.mpeg', '.mpg', '.nuv', '.oga',
        '.ogg', '.ogm', '.ogv', '.ogx', '.pbm', '.pcx', '.pgm', '.png', '.ppm',
        '.qt', '.ra', '.rm', '.rmvb', '.spx', '.svg', '.svgz', '.tga', '.tif',
        '.tiff', '.vob', '.wav', '.webm', '.wmv', '.xbm', '.xcf', '.xpm',
        '.xspf', '.xwd', '.yuv', '.swf',
    ],
    'other': [
        '.aux', '.bak', '.git', '.log', '.o', '.pyc', '.swp', '.tmp',
    ],
    'doc': [
        '.doc', '.htm', '.html', '.pdf', '.rtf', '.txt', '.xhtml',
    ],
    'data': [
        '.xml', '.csv', '.json',
    ],
    'src': [
        '.c', '.cc', '.cpp', '.go', '.h', '.hs', '.js', '.pl', '.py', '.sh',
        '.vim', '.php', '.css', '.java'
    ],
}

MAPPING = {
    'RESET': '0', # reset to "normal" color

    # directories
    'DIR': '48;5;189',
    'STICKY_OTHER_WRITABLE': '34;48;5;189',
    'OTHER_WRITABLE': '31;48;5;189',
    'STICKY': '01;34;48;5;189',

    'LINK': '36', # symbolic link. (If you set this to 'target' instead of a
                 # numerical value, the color is as for the file pointed to.)
    'FILE': '38;5;243',         # regular file: use no color at all
    'FIFO': '40;33',       # pipe
    'BLK': '40;33;01', # block device driver
    'CHR': '40;33;01', # character device driver

    'SOCK': '38;5;243;48;5;227',
    'DOOR': '38;5;243;48;5;227',

    'ORPHAN': '40;31',     # symlink to nonexistent file, or non-stat'able file
    'SETUID': '37;41',     # file that is setuid (u+s)
    'SETGID': '30;43',     # file that is setgid (g+s)
    'CAPABILITY': '30;41', # file with capability

    'EXEC': '31',  # This' is for files with execute permission

    'archive': '38;5;130',
    'media': '38;5;93',
    'other': '38;5;249',
    'doc': '0',
    'data': '38;5;26',
    'src': '38;5;28',
}

TERMS = ['xterm-256color', 'screen-256color']

def show():
    for kind, code in MAPPING.items():
        print '\x1b[%sm%s\x1b[0m' %(code,kind)

def main():
    for term in TERMS:
        print 'TERM', term

    for kind, code in MAPPING.items():
        for value in KINDS.get(kind, [kind]):
            print value, code

if __name__ == '__main__':
    main()
    # show()
