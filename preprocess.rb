require_relative 'preprocessor.rb'
require 'redcarpet'

if ARGV.length < 1
  puts "usage: ruby preprocessor.rb filename"
  puts "(processes <filename>.md and writes output to ../sindarin-release/<filename>.html)"
  exit 1
end

filename = ARGV[0]
template_filename = 'template-2.html'
input_filename = filename + ".md"
output_filename = "../sindarin-release/#{filename}.html"

normalized_relative_path = input_filename.gsub('./', '')
dir_levels = normalized_relative_path.split('/').count
path_to_root_dir = '.'
if dir_levels > 1
  path_to_root_dir = (['..'] * (dir_levels - 1)).join('/')
end

input = File.open(input_filename, 'r')
output = File.open(output_filename, 'w')
template = File.open(template_filename, 'r')

while line = template.gets
  line = line.gsub('$ROOT$', path_to_root_dir)

  if line['ABRACADABRA']
    markdown = ""
    Preprocessor.new(input).each_processed_line do |line|
      markdown += line
    end
    markdown_converter = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, quote: true, footnotes: true, disable_indented_code_blocks: true)
    output << markdown_converter.render(markdown)
      .gsub("&#39;", '&rsquo;')
      .gsub(/<p>!!([^<]+)<\/p>/, '<div class="\1">')
      .gsub(/<p>\/![^<]*<\/p>/, '</div>')
  else
    output << line
  end
end

input.close
output.close
template.close
