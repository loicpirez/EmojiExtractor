#!/usr/bin/python3
import base64
import os
import getopt
import sys

from bs4 import BeautifulSoup
from urllib.request import urlopen


class parsedEmoji:
    key = []
    description = ""
    rawApplePng = ""
    rawGooglePng = ""
    rawTwitterPng = ""
    rawEmojiOnePng = ""
    rawFacebookPng = ""
    rawMessengerPng = ""
    rawSamsungPng = ""
    rawWindowsPng = ""
    rawGmailGif = ""
    rawSoftBankGif = ""
    rawDocomoGif = ""
    rawKDDIGif = ""


class parsedArgs:
    messenger_format = False
    font_format = False
    disable_crop = False
    verbose = False
    remove_old_emoji = False


def print_verbose(string, parsedargs):
    if parsedargs.verbose:
        print(string, end='')


def parse_key(row):
    tmp = row.findAll('td', {'class': 'code'})
    a_href = tmp[0].findAll('a')
    return a_href[0].text.split(' ')


def get_emoji_from_td(td, count_col_pos, currentEmoji, args):
    if 'miss' in str(td):
        value = "missing"
    else:
        try:
            value = td.find('img').get('src').replace("data:image/png;base64,", "")
        except:
            pass
    if count_col_pos == 0:
        currentEmoji.rawApplePng = value
    elif count_col_pos == 1:
        currentEmoji.rawGooglePng = value
    elif count_col_pos == 2:
        currentEmoji.rawTwitterPng = value
    elif count_col_pos == 3:
        currentEmoji.rawEmojiOnePng = value
    elif count_col_pos == 4:
        currentEmoji.rawFacebookPng = value
    elif count_col_pos == 5:
        currentEmoji.rawMessengerPng = value
    elif count_col_pos == 6:
        currentEmoji.rawSamsungPng = value
    elif count_col_pos == 7:
        currentEmoji.rawWindowsPng = value
    elif count_col_pos == 8:
        currentEmoji.rawGmailGif = value
    elif count_col_pos == 9:
        currentEmoji.rawSoftBankGif = value
    elif count_col_pos == 10:
        currentEmoji.rawDocomoGif = value
    elif count_col_pos == 11:
        currentEmoji.rawKDDIGif = value


def parse_row(row, line, args):
    currentemoji = parsedEmoji
    if not row.find_all('th') and "..." not in row.findAll('td', {'class': 'andr'})[0].text:
        count_col_pos = 0
        descriptionbeenset = False
        currentemoji.key = parse_key(row)
        if args.font_format:
            if "U+FE0F" in currentemoji.key:
                currentemoji.key.remove("U+FE0F")
            if "U+2642" in currentemoji.key:
                currentemoji.key.remove("U+2642")
                currentemoji.key.insert(0, "U+2642")
            if "U+2640" in currentemoji.key:
                currentemoji.key.remove("U+2640")
                currentemoji.key.insert(0, "U+2640")
            if "U+200D" in currentemoji.key:
                currentemoji.key.remove("U+200D")
                currentemoji.key.insert(1, "U+200D")

        for td in row.find_all('td'):
            if 'code' not in str(td) and 'name' in str(td) and descriptionbeenset is False:
                currentemoji.description = td.text
                descriptionbeenset = True
            if 'rchars' not in str(td) and 'emojiOne recharred' not in str(td) and 'code' not in str(
                    td) and 'name' not in str(td):
                get_emoji_from_td(td, count_col_pos - 3, currentemoji, args)
            count_col_pos += 1
        print_verbose(currentemoji.key, args)
        print_verbose(currentemoji.description, args)
        print_verbose("Done.\n", args)
    else:
        print_verbose("Current row is not valid.\n", args)
    return currentemoji


def extract_base64(base64_content, filename, path, extension, args):
    if filename:
        if args.font_format:
            file_n = path + filename + "." + extension
        elif args.messenger_format:
            file_32 = path + "messenger_emoji_" + filename + "_32." + extension
            file_64 = path + "messenger_emoji_" + filename + "_64." + extension
        else:
            file_n = path + filename + "." + extension

        if args.messenger_format:
            with open(file_32, "wb") as file:
                file.write(base64.decodebytes(bytes(base64_content.encode('UTF-8'))))
            with open(file_64, "wb") as file:
                file.write(base64.decodebytes(bytes(base64_content.encode('UTF-8'))))
        else:
            with open(file_n, "wb") as file:
                file.write(base64.decodebytes(bytes(base64_content.encode('UTF-8'))))

        if extension is "png" and not args.disable_crop:
            if args.messenger_format:
                os.system("convert " + file_32 + " -trim +repage " + file_32)
                os.system("convert " + file_32 + " -resize 42x42 " + file_32)
                os.system("convert " + file_64 + " -trim +repage " + file_64)
                os.system("convert " + file_32 + " -resize 74x74 " + file_32)
            elif args.font_format:
                os.system("convert " + file_n + " -resize 160x160 -quality 100 " + file_n)
            else:
                os.system("convert " + file_n + " -trim +repage " + file_n)


def extract_images(emojiClass, args):
    name = ""
    i = 0
    if len(emojiClass.key) == 1:
        name = (emojiClass.key[0].replace("U+", "")).lower()
    else:
        for k in emojiClass.key:
            k = k.replace("U+", "").lower()
            if i == 0:
                name = k
            else:
                if args.font_format:
                    name = name + "_" + k
                elif args.messenger_format:
                    name = name + "_" + k
                else:
                    name = name + "-" + name
            i += 1
    if emojiClass.rawApplePng is not "missing":
        extract_base64(emojiClass.rawApplePng, name, "unicode.org/apple/", "png", args)
    if emojiClass.rawGooglePng is not "missing":
        extract_base64(emojiClass.rawGooglePng, name, "unicode.org/google/", "png", args)
    if emojiClass.rawTwitterPng is not "missing":
        extract_base64(emojiClass.rawTwitterPng, name, "unicode.org/twitter/", "png", args)
    if emojiClass.rawEmojiOnePng is not "missing":
        extract_base64(emojiClass.rawEmojiOnePng, name, "unicode.org/emojione/", "png", args)
    if emojiClass.rawFacebookPng is not "missing":
        extract_base64(emojiClass.rawFacebookPng, name, "unicode.org/facebook/", "png", args)
    if emojiClass.rawMessengerPng is not "missing":
        extract_base64(emojiClass.rawMessengerPng, name, "unicode.org/messenger/", "png", args)
    if emojiClass.rawSamsungPng is not "missing":
        extract_base64(emojiClass.rawSamsungPng, name, "unicode.org/samsung/", "png", args)
    if emojiClass.rawWindowsPng is not "missing":
        extract_base64(emojiClass.rawWindowsPng, name, "unicode.org/windows/", "png", args)
    if emojiClass.rawGmailGif is not "missing":
        extract_base64(emojiClass.rawGmailGif, name, "unicode.org/gmail/", "gif", args)
    if emojiClass.rawSoftBankGif is not "missing":
        extract_base64(emojiClass.rawSoftBankGif, name, "unicode.org/softbank/", "gif", args)
    if emojiClass.rawDocomoGif is not "missing":
        extract_base64(emojiClass.rawDocomoGif, name, "unicode.org/docomo/", "gif", args)
    if emojiClass.rawKDDIGif is not "missing":
        extract_base64(emojiClass.rawKDDIGif, name, "unicode.org/kddi/", "gif", args)


def emojilist(args):
    print_verbose("Downloading emoji list from unicode.org...\n", args)
    os.chdir(".tmp/")
    os.system("wget -N http://www.unicode.org/emoji/charts/full-emoji-list.html")
    print_verbose("Stocking this file into memory...\n", args)
    content = urlopen("file:///" + os.getcwd() + "/full-emoji-list.html").read()
    os.chdir("..")
    print_verbose("Parsing HTML file...\n", args)
    soup = BeautifulSoup(content, "html5lib")
    print_verbose("Extracting information from parsed file...\n", args)
    line = 0
    for row in soup.find_all('tr'):
        print_verbose("Parsing row of array ", args)
        print_verbose(line, args)
        print_verbose("...\n", args)
        extract_images(parse_row(row, line, args), args)
        line += 1


def usage():
        print("[-v][--verbose] : Debug execution of the script")
        print("[-m][--messenger-format] : Export to messenger app format")
        print("[-f][--font-format] : Export to iOS/Android font format")
        print("[-d][--disable-crop] : Disable Crop operation on emoji")
        print("[-r][--remove-old-emoji]: Clean current directory before execution")


def print_args(args):
    if args.verbose:
        print("Args => -v (--verbose)")
    if args.messenger_format:
        print("Args => -m (--messenger-format")
    if args.font_format:
        print("Args => -f (--font-format)")
    if args.disable_crop:
        print("Args => -d (--disable-crop)")
    if args.remove_old_emoji:
        print("Args => -r (--remove-old-emoji)")


def main():
    print("EmojiExtractor is running...")
    argsclass = parsedArgs
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hvmfdr",
                                   ["--help", "--verbose", "--messenger-format", "--font-format", "--disable-crop",
                                    "--remove-old-emoji"])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-v", "--verbose"):
            argsclass.verbose = True
        elif o in ("-m", "--messenger-format"):
            argsclass.messenger_format = True
        elif o in ("-f", "--font-format"):
            argsclass.font_format = True
        elif o in ("-d", "--disable-crop"):
            argsclass.disable_crop = True
        elif o in ("-r", "--remove-old-emoji"):
            argsclass.remove_old_emoji = True
    if argsclass.verbose:
        print_args(argsclass)
    if argsclass.remove_old_emoji:
        os.system("find . -name \"emoji/*.png\" -delete && find . -name \"emoji/*.gif\" -delete")
    if not argsclass.verbose:
        print("Please enable verbose for debug output.")
    emojilist(argsclass)


# verbose args

if __name__ == '__main__':
    main()
