#!/usr/bin/env ruby
require 'rest-client'
require 'optparse'
require 'yaml'

Options = Struct.new(:server,:username,:password,:yaml)

class Parser
  def self.parse(options)
    args = Options.new()
    
    args.server="localhost:9393"
    args.yaml = "streams.yml"

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: xd-admin.rb [options]"

      opts.on("-sSERVER", "--server=SERVER", "base Admin URI of XD server") do |s|
        args.server = s
      end
      
      opts.on("-yYAML", "--yaml=YAML", "Yaml stream definitions file") do |s|
        args.server = s
      end
      
      opts.on("-uUSERNAME", "--username=USERNAME", "username") do |u|
        args.username = u
      end
      
      opts.on("-pPASSWORD", "--password=PASSWORD", "password") do |p|
        args.password = p
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end
    opt_parser.parse!(options)
    return args
  end
end



class XDAdmin
  
  attr_accessor :baseUrl, :username, :password
  
  
   def initialize(baseUrl,username,password)
     @baseUrl = baseUrl
     @username = username
     @password = password
   end

   def create_stream(name, dsl)
      url = @baseUrl + "/streams/definitions.json"
     RestClient::Request.new(
         :method => :post,
          :url => url,
          :user => @username,
          :password => @password,
          :headers => { :accept => :json,
          :content_type => "application/x-www-form-urlencoded" },
          :payload => {:name => name, :definition => dsl, :deploy => false}
      ).execute
    end
    
    def deploy_stream(name,deploymentProperties=nil)
       url = @baseUrl + "/streams/deployments/#{name}.json"
      RestClient::Request.new(
          :method => :post,
           :url => url,
           :user => @username,
           :password => @password,
           :headers => { :accept => :json,
           :content_type => "application/x-www-form-urlencoded" },
           :payload => {:properties=>deploymentProperties}
       ).execute
     end
end

args = options = Parser.parse ARGV

xd = XDAdmin.new(args.server, args.username, args.password)

streams = YAML.load_file(args.yaml)

streams.each do |k,v|
  xd.create_stream(k,v['definition'])
end

streams.each do |k,v|
  xd.deploy_stream(k,v['deploy'])
end