module SubnauticalIntrusion
  module States
    class MainMenu < CyberarmEngine::GuiState
      def setup
        self.show_cursor = true

        theme(THEME)

        flow(width: 1.0, height: 1.0, background: 0xff_1a5fb4) do
          stack(width: 0.25, min_width: 440, height: 1.0, padding: 24) do
            title "Subnautical Intrustion".upcase
            button("PLAY") { pop_state; push_state(States::Game) }
            flow(fill: true)
            button("EXIT") { close }
          end

          stack(fill: true, height: 1.0, background: 0x88_ff5fb4, padding: 24) do
            tagline "You and you're submarine are in a battle simulation."
            tagline "Escape without beaching your submarine and getting detected by enemy ships."
          end
        end
      end
    end
  end
end
