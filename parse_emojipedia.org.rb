#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'net/http'

class EmojiPedia
  def self.create_data_struct(unicode, image)
    emoji_struct = Struct.new(:unicode_values, :image_list)
    return emoji_struct.new(unicode, image)
  end

  def self.get_webpage(url)
    begin
      html_data = open(url).read
      data = Nokogiri::HTML(html_data)
    rescue OpenURI::HTTPError => ex
      return 'empty'
    end
    return data
  end

  def self.parse_emoji_list(url)
    data = get_webpage(url)
    grid = data.css('article')
    emoji_url_list = Array.new
    grid.css('a').each do |row|
      unless row['href'] =~ /unicode-/
        unless row['href'] =~ /emoji-/
          puts 'http://emojipedia.org' + row['href']
          emoji_url_list.push('http://emojipedia.org' + row['href'])
        end
      end
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

  def self.extract_ios(url)
    ios = get_webpage(url)
    if ios =~ /empty/
      return 'empty'
    end
    (ios.css('.vendor-set-emoji-image').to_s.split('=')).each do |extract|
      if extract =~ /http/
        return extract[1..-9]
      end
    end
    return 'empty'
  end

  def self.get_image_url_from_data(data, style_list, url)
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
              if platform =~ /apple/
                unless extract_ios('http://emojipedia.org/apple/ios-10.0/' + url.split('/')[-1]) =~ /empty/
                  image_url = extract_ios('http://emojipedia.org/apple/ios-10.0/' + url.split('/')[-1])
                end
                unless extract_ios('http://emojipedia.org/apple/ios-10.3/' + url.split('/')[-1]) =~ /empty/
                  image_url = extract_ios('http://emojipedia.org/apple/ios-10.3/' + url.split('/')[-1])
                end
              end
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
    image_list = get_image_url_from_data(data, style_list, url)
    emoji_data = create_data_struct(unicode_values, image_list)
    return emoji_data
  end
end


emojipedia = EmojiPedia
appleold_url = '/apple/ios-10.0/'
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
emoji_dex = '/emojidex/1.0.24/'
style = [appleold_url, apple_url, google_url, windows_url, samsung,
         lg, htc, facebook, messenger, twitter, firefox_os,
         emoji_one, emoji_dex, '/emojipedia/5.0/']

i = 0

emojipedia.parse_emoji_list(ARGV[0]).each do |url|
  puts i
  puts url
  emoji_data = emojipedia.extract_info_from_url(url, style)

  file_name = ''
  emoji_data.unicode_values.each do |unicode|
    file_name = file_name + '_' + unicode
  end
  file_name = file_name[1..-1].gsub('U+', '') + '.png'
  emoji_data.image_list.each do |array|
    if array[1].nil?
      puts 'Warning : empty'
    else
      unless array[1].include?('empty')
        print 'Downloading '
        print file_name
        print ' as '
        print array[0]
        puts ' emoji style ...'
        download_link = array[1]
        output_file = 'emojipedia.org' + '/' + array[0] + '/'
        mv_line = 'mv ' + output_file + download_link.split('/')[-1] + ' ' + output_file + file_name.downcase
        wget_line = 'wget --quiet -N  ' + download_link + ' -P ' + output_file
        system(wget_line)
        system(mv_line)
      end
    end
  end
  i += 1
end

