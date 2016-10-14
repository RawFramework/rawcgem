require_relative './command_shell.rb'
require 'net/http'
require 'yaml'
require_relative './scaffold.rb'
#require 'jasmine'
require 'uri'
require 'rubygems'
require 'zip'
require 'colorize'




task :rake_dot_net_initialize do
  #throw error if we are not in the root of the folder
  if not File.exist?('dev.yml') then
    puts "You are not in the root folder of a RAW Framework Core project!!".colorize(:red)
    raise "Error!"
  end
  
  yml = YAML::load File.open("dev.yml")
  @solution_name = "#{ yml["solution_name"] }.sln"
  @solution_name_sans_extension = "#{ yml["solution_name"] }"
  @mvc_project_directory = yml["mvc_project"]
  @dl_project_directory = yml["dl_project"]
  @database_name = yml["database_name"]
  @project_name = yml["solution_name"]
  
  @test_project = yml["test_project"]
  @test_dll = "./#{ yml["test_project"] }/bin/debug/#{ yml["test_project"] }.dll "
  
  @sh = CommandShell.new
  
  #build?
end

desc "builds and run the website"
task :default => [:build]

desc "creates a new app, unzips the template and initialize the app"
task :newApp  do
  #ask for appName
  puts "Enter app name(case sensitive):".colorize(:cyan)
  appname = STDIN.gets.chomp
  #filename = "#{appname}/#{appname}.zip"
  filename =  File.join( File.dirname(__FILE__), 'rawcore.zip' )
  #create the folder
  Dir.mkdir appname
  
  puts "Inflating template and replacing tokens......".colorize(:light_green)
  Zip::File.open(filename) do |zip_file|
  
  toRepalce = '__NAME__'
  # Handle entries one by one
  zip_file.each do |entry|
      unzipped =entry.name.gsub(toRepalce,appname)
      entry.extract("#{appname}/#{unzipped}")
      #skip dlls, images, fonts, javascript, css, etc
      if !((unzipped.include? ".dll") || 
           (unzipped.include? ".png") || 
           (unzipped.include? ".jpg") || 
           (unzipped.include? ".gif") ||
           (unzipped.end_with? ".css") || 
           (unzipped.end_with? ".js") || 
           (unzipped.end_with? ".map") ||
           (unzipped.include? ".less") || 
           (unzipped.include? ".otf") || 
           (unzipped.include? ".eot") || 
           (unzipped.include? ".svg") || 
           (unzipped.include? ".ttf") || 
           (unzipped.include? ".woff")) && 
           entry.size >0 then
              # load the file as a string
              data = File.read("#{appname}/#{unzipped}") 
              # globally substitute "install" for "latest"
              filtered_data = data.gsub(toRepalce,appname) 
              # open the file for writing
              File.open("#{appname}/#{unzipped}", "w") do |f|
                f.write(filtered_data)
              end
      end
    end
  end
  #at this point the zip file has been downloaded, uncompress and delete it
  puts "Get app packages......".colorize(:light_green)
  sh "dotnet restore #{appname}/#{appname}.Web/project.json"
  sh "dotnet restore #{appname}/Generator/project.json"

  puts "Building......".colorize(:light_green)
  sh "dotnet build #{appname}/Generator/project.json -o #{appname}/XmlGenerator -f netcoreapp1.0"
  sh "dotnet build #{appname}/#{appname}.Web/project.json"
  puts "Done!".colorize(:light_blue)
  puts "======================================================================================".colorize(:cyan)
  puts "RAW framework follows Database First approach, expects that a DB schema already exists".colorize(:light_yellow)
  puts "The application is configured to connect to a local SQL server express".colorize(:light_yellow)
  puts "Change the following connection(if necessary) before you start scaffolding".colorize(:light_yellow)
  puts "Data Source=localhost\\SQLEXPRESS;Initial Catalog=#{appname};Trusted_Connection=True;".colorize(:light_green)
  puts "The connection string is in two appsettings.json files under the following folders:".colorize(:light_yellow)
  puts "- #{appname}.Web".colorize(:light_green)
  puts "- Generator".colorize(:light_green)
  puts "======================================================================================".colorize(:cyan)
  puts "Type rawc help for documentation".colorize(:light_yellow)
  puts "Type cd #{appname} to start scaffolding!".colorize(:light_green)
end

desc "builds the solution"
task :build => :rake_dot_net_initialize do
  #get packages
  sh "dotnet restore #{@project_name}.Web/project.json"
  #run the app
  sh "dotnet build #{@project_name}.Web/project.json" 
end

desc "builds the Generator"
task :buildGen => :rake_dot_net_initialize do
  #get packages
  sh "dotnet restore Generator/project.json"
  #run the app
  sh "dotnet build Generator/project.json -o XmlGenerator -f netcoreapp1.0" 
end

desc "run the application"
task :run => :rake_dot_net_initialize do
  sh "dotnet run --project #{@project_name}.Web/project.json" 
end



desc "Show help"
task :help do
  sh "start https://rawframework.github.io/rawfdotnetcore/index.html"
end

