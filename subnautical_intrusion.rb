module SubnauticalIntrusion
  ROOT_PATH = File.expand_path("..", __FILE__)
  DESIGN_RESOLUTION_WIDTH = 1024
end

unless RUBY_ENGINE == "mruby"
  require_relative "../cyberarm_engine/lib/cyberarm_engine"

  require_relative "lib/version"
  require_relative "lib/window"
  require_relative "lib/input"
  require_relative "lib/entity"
  require_relative "lib/sonar_entity"
  require_relative "lib/player_entity"
  require_relative "lib/states/main_menu"
  require_relative "lib/states/game"
end

SubnauticalIntrusion::Window.new(width: 1280, height: 800, resizable: true).show
