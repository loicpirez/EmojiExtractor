# Emoji Extractor

Extract emoji from unicode.org and emojipedia.org into PNG and GIF format from different styles.
### Unicode.org
  - Apple (iOS)
  - Google (Android)
  - Twitter
  - EmojiOne
  - Facebook
  - Messenger (from Facebook)
  - Windows
  - Gmail
  - SoftBank
  - Docomo
  - KDDI

### Emojipedia.org
  - Apple (iOS)
  - Google (Android)
  - Twitter
  - EmojiOne
  - Facebook
  - Messenger (from Facebook)
  - Windows
  - LG
  - Samsung
  - Mozilla
  - HTC
  - Emojipedia

# Unicode.org (./parse_unicode.org.py)

### Dependencies
  - ImageMagick
  - Python 3
  - BeautifulSoup (Python 3 module)

### How to use

$ python3 ./parse_unicode.org.py

Options:

    -v / --verbose] : Debug execution of the script
    -m / --messenger-format] : Export to messenger app format
    -f / --font-format] : Export to iOS/Android font format
    -d / --disable-crop] : Disable Crop operation on emoji
    -r / --remove-old-emoji]: Clean current directory before execution

# Emojipedia (./parse_emojipedia.org.rb)

### Dependencies

$ ruby ./parse_emojipedia.org.rb [URL]

### Options

    URL Link of a emojipedia brand page (for exemple: emojipedia.org/apple/)

:warning: This is a WIP. You may need to tunes the program to fill your needs.

Already extracted PNG/GIF are available in folders.
