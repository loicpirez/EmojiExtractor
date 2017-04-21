#!/usr/bin/ruby

unless ARGV[0] and ARGV[1]
  puts "Usage:\n\t[folder_emojitools] [folder_emojipedia]"
  exit (1)
end

EmojiList = Struct.new(:file_list, :modified_file_list)

def get_file_list(path, extension)
  Dir[path + '/*.' + extension]
end

def without_path(array)
  array.each {|sub| sub.replace(sub.split('/')[-1])}
end

emojitools = EmojiList.new(get_file_list(ARGV[0], 'png'), without_path(get_file_list(ARGV[0], 'png')))
emojipedia = EmojiList.new(get_file_list(ARGV[1], 'png'), without_path(get_file_list(ARGV[1], 'png')))

def rename_gender(filename)
  type = filename.split('/')[-1]
  extension = '.' + filename.split('.')[-1]
  gender_filename = ''
  split = type.split('_')
  return filename if split.length == 1
  split.each {|sub| sub.replace(sub.gsub(/#{extension}/, ''))}
  split.each {|sub|
    split.insert(0, split.delete(sub)) if sub =~ /2642/ or sub =~ /2640/
    split.insert(0, split.delete(sub)) if sub =~ /200d/
  }
  split.each_with_index do |sub, index|
    if index == 0
      gender_filename = sub
    elsif index == split.length-1
      gender_filename += '_' + sub + extension
    else
      gender_filename += '_' + sub
    end
  end
  gender_filename
end

emojipedia.modified_file_list.each do |filename|
  filename.replace(filename.gsub(/_fe0f/, '')) if filename =~ /_fe0f/
  filename.replace(filename.gsub(/fe0f_/, '')) if filename =~ /fe0f_/
  filename.replace(filename.gsub(/fe0f/, '')) if filename =~ /fe0f/
  filename.replace(rename_gender(filename)) if filename =~ /2640/ or filename =~ /2642/
end

target_dimension = `identify #{emojitools.file_list[0]} | awk '{print $3}'`
unless target_dimension =~ /\dx\d/
  puts('Error while read dimension of image')
  exit(1)
end
target_dimension = target_dimension[0..-2] + "\!"
`rm -rf out && mkdir out && cp -r #{ARGV[0]}/* out/`

(emojipedia.modified_file_list & emojitools.modified_file_list).each_with_index do |same, index|
  puts "#{emojipedia.file_list[emojipedia.modified_file_list.index(same)]}"
  puts "out/#{(emojitools.file_list[emojitools.modified_file_list.index(same)]).split('/')[-1]}"
  `cp -r #{emojipedia.file_list[emojipedia.modified_file_list.index(same)]} out/#{(emojitools.file_list[emojitools.modified_file_list.index(same)]).split('/')[-1]}`
  `convert out/#{(emojitools.file_list[emojitools.modified_file_list.index(same)]).split('/')[-1].gsub(/ /, '')} -geometry #{target_dimension} out/#{(emojitools.file_list[emojitools.modified_file_list.index(same)]).split('/')[-1].gsub(/ /, '')}`
  puts "#{index} => #{same}"
end
