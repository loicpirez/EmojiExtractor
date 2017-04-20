#!/usr/bin/env sh
cd ..
#ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-1.0/"
#ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-2.0/"
#ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-3.0/"
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-4.0/"
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-5.0/"
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-6.0/"
python3 parse_unicode.org.py -v -f
cd -
