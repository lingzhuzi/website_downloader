require 'uri'

class DownloaderCommon
  class << self
    def valid_url?(url)
      url = url.downcase
      ['javascript:', '#', 'mailto:', 'irc:'].each do |str|
        return false if url.start_with?(str)
      end

      true
    end

    def complete_url(base_url, url)
      return nil if !valid_url?(url)

      href = url.downcase
      if href.start_with?('http://') || href.start_with?('https://')
        return url
      elsif href.start_with?('//')
        URI.parse(base_url).scheme + ":" + url
      else
        return URI.join(base_url, url).to_s
      end
    end

    def pure_url(url)
      url.split(/[#?]/)[0]
    end

    def add_html_ext(file_name)
      return file_name if file_name.end_with?('.html')
      return file_name if file_name.end_with?('.htm')
      return file_name if file_name.end_with?('.shtml')

      ['.jsp', '.php'].each do |ext|
        file_name = file_name.gsub(ext, '.html')
      end
      file_name = file_name + '.html' unless file_name.end_with?('.html')

      file_name
    end

    def dir_name(file_name)
      arr = file_name.split('/')
      arr[-1] = nil
      arr.join('/')
    end

    def make_dir_p(dir_name)
      path = ''
      dir_name.split('/').each do |name|
        path << name << '/'
        Dir.mkdir(path) unless File.exist?(path)
      end
    end

    def open_file(file_name, permission)
      dir_name  = dir_name(file_name)
      make_dir_p(dir_name)

      unless File.exist?(file_name)
        file = File.open(file_name, permission)
        yield(file) if block_given?
        file.close
      end
    end


  end
end