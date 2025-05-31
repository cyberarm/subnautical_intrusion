module SubnauticalIntrusion
  class Window < CyberarmEngine::Window
    def setup
      self.caption = "Subnautical Intrusion v#{SubnauticalIntrusion::VERSION} (Gosu Game Jam 8 Entry)"

      # push_state(States::MainMenu)
      push_state(States::Game)
    end
  end
end
