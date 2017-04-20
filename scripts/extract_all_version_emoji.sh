#!/usr/bin/env sh
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-6.0/" | tee logs/6.0.log
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-5.0/" | tee logs/5.0.log
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-4.0/" | tee logs/4.0.log
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-3.0/" | tee logs/3.0.log
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-2.0/" | tee logs/2.0.log
ruby parse_emojipedia.org.rb "http://emojipedia.org/emoji-1.0/" | tee logs/1.0.log
python3 parse_unicode.org.py -v -f | tee logs/parse_unicode.log
