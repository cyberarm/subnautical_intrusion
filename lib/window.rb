module SubnauticalIntrusion
  class Window < CyberarmEngine::Window
    def setup
      self.caption = "Subnautical Intrusion v#{SubnauticalIntrusion::VERSION} (Gosu Game Jam 8 Entry)"

      push_state(DEBUG_MODE ? States::Game : States::MainMenu)
    end
  end
end
