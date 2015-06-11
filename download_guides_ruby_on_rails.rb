require './website_downloader'

options = {
  website_url: 'http://guides.rubyonrails.org',
  limit_url: '/',
  index_url: '/index.html',
  export_dir: './Guides_Ruby_on_Rails',
  selectors: {link: {selector: '#mainCol a',      attr: 'href'} }
}

downloader = WebsiteDownloader.new(options)
downloader.start