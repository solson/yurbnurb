require 'cinch'
require 'patron'
require 'uri'
require 'htmlentities'

bot = Cinch::Bot.new do
    configure do |c|
        c.server   = "localhost"
        c.nick     = "yurbnurb"
        c.channels = ["#programming", "#offtopic", "#bots"]
    end
    
    helpers do
        def get_title(body)
            title = body[/<title>(.*?)<\/title>/m, 1]
            HTMLEntities.decode_entities(title).gsub("\n", " ").strip if title
        end
        
        def yubnub(query)
            sess = Patron::Session.new
            sess.timeout = 10
            sess.base_url = "http://yubnub.org"
            sess.headers['User-Agent'] = 'yurbnurb/1.0'
            
            r = sess.get("/parser/parse?command=" + URI.escape(query))
            
            return "HTTP error code #{r.status} while executing command (#{r.url})" if r.status >= 400
            
            if r.body[0..1000].include?("<html") || r.body[0..1000].include?("<!doctype")
                title = get_title(r.body)
                return title ? "#{r.url} \"#{title}\"" : r.url
            end
            
            return r.url if r.body.chomp.include?("\n")
            
            r.body.chomp
        end
    end
    
    on :message, /^#{Regexp.escape nick}[:,]\s*(.+)$/ do |m, query|
        m.reply("#{m.user.nick}: #{yubnub(query)}")
    end
end

bot.start

