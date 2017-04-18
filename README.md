# Emoji Extractor

Extract emoji from unicode.org into PNG and GIF format from different styles...

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

... into different format :
  - Facebook / Messenger Android Package File assets
  - EmojiTools
  - Simple extract (no operation done, no specific format)

### Dependencies
  - ImageMagick
  - Python 3
  - BeautifulSoup (Python 3 module)

### How to use

$ python3 ./extract.py

Options:

    -v / --verbose] : Debug execution of the script
    -m / --messenger-format] : Export to messenger app format
    -f / --font-format] : Export to iOS/Android font format
    -d / --disable-crop] : Disable Crop operation on emoji
    -r / --remove-old-emoji]: Clean current directory before execution

:warning: This is a WIP. You may need to tunes the program to fill your needs.
