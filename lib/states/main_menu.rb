module SubnauticalIntrusion
  module States
    class MainMenu < CyberarmEngine::GuiState
      def setup
        self.show_cursor = true
      end

      def draw
        Gosu.draw_rect(0, 0, window.width, window.height, 0xff_1a5fb4)

        super
      end
    end
  end
end
