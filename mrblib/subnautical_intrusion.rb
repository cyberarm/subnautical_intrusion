module SubnauticalIntrusion
  ROOT_PATH = File.expand_path("../..", __FILE__)
  DESIGN_RESOLUTION_WIDTH = 1024
  DEBUG_MODE = RUBY_ENGINE == "mruby" ? false : ARGV.join.include?("--debug")
end

unless RUBY_ENGINE == "mruby"
  begin
    require_relative "../../cyberarm_engine/lib/cyberarm_engine"
  rescue LoadError => e
    puts e

    require "cyberarm_engine"
  end

  require_relative "version"
  require_relative "window"
  require_relative "theme"
  require_relative "input"
  require_relative "entity"
  require_relative "sonar_entity"
  require_relative "player_entity"
  require_relative "states/main_menu"
  require_relative "states/game"
  require_relative "states/game_over"
  require_relative "states/game_won"

  SubnauticalIntrusion::Window.new(width: 1280, height: 800, resizable: true).show
end

