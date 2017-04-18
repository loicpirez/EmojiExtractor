#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'

class EmojiPedia
  def self.create_data_struct(unicode, image)
      emoji_struct = Struct.new(:unicode_values, :image_list)
      return emoji_struct.new(unicode, image)
  end

  def self.get_webpage(url)
    html_data = open(url).read
    data = Nokogiri::HTML(html_data)
    return data
  end

  def self.parse_emoji_list(url)
    data = get_webpage(url)
    grid = data.css('.emoji-grid')
    emoji_url_list = Array.new
    grid.css('a').each do |row|
      emoji_url_list.push('http://emojipedia.org' + row['href'])
    end
    return emoji_url_list
  end

  def self.get_unicode_from_data(data)
    unicode_values = []
    data.to_s.split(' ').each do |block|
      if block.include?('U+')
        unicode_values.push(block.split('<')[0])
      end
    end
    return unicode_values
  end

  def self.get_image_url_from_data(data, style_list)
    image_list = []
    image_url = 'empty'
    platform = 'empty'
    data.css('.vendor-container').css('.vendor-image').each do |search|
      elements = search.to_s.split(' ')
      elements.each do |row|
        if row =~ /href/
          style_list.each do |style|
            if row.include?(style)
              platform = row[7...-2].split('/')[0]
            end
          end
        else
          if row =~ /srcset=/
            if platform =~ /empty/
              image_url = row.split('srcset="')[1]
            else
              current_image = [platform, image_url]
              image_list.push(current_image)
              platform = 'empty'
            end
          end
        end
      end
    end
    return image_list
  end

  def self.extract_info_from_url(url, style_list)
    data = get_webpage(url)
    unicode_values = get_unicode_from_data(data)
    image_list = get_image_url_from_data(data, style_list)
    emoji_data = create_data_struct(unicode_values, image_list)
    return emoji_data
  end
end


emojipedia = EmojiPedia

apple_url = '/apple/ios-10.3/'
google_url = '/google/android-7.1/'
windows_url = '/microsoft/windows-10-creators-update/'
samsung = '/samsung/galaxy-s8-revised/'
lg = '/lg/g5/'
htc = '/htc/sense-7/'
facebook = '/facebook/2.0/'
messenger = '/messenger/1.0/'
twitter= '/twitter/twemoji-2.2.3/'
firefox_os = '/mozilla/firefox-os-2.5/'
emoji_one = '/emoji-one/2.2.5/'
emoji_dex = '/emojidex/1.0.24'
style = [apple_url, google_url, windows_url, samsung,
         lg, htc, facebook, messenger, twitter, firefox_os,
         emoji_one, emoji_dex, '/emojipedia/']

emojipedia.parse_emoji_list(ARGV[0]).each do |url|
  emoji_data = emojipedia.extract_info_from_url(url, style)
  emoji_data.unicode_values.each do |unicode|
    puts unicode
  end
  emoji_data.image_list.each do |array|
    print('style:')
    print(array[0])
    print(' url: ')
    puts(array[1])
  end
  STDIN.gets()
end
