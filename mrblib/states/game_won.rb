module SubnauticalIntrusion
  module States
    class GameWon < CyberarmEngine::GuiState
      def setup
        self.show_cursor = true

        theme(THEME)

        flow(width: 1.0, height: 1.0, background: 0x88_222222, padding: 64) do
          stack(width: 0.33)
          stack(fill: true, height: 1.0) do
            banner "MISSION SUCCESS"
            tagline @options[:reason] || "Because reasons. :)"
            caption "Took: #{((previous_state&.simulation_time).to_i / 1000.0)} seconds"

            button "REPLAY" do
              while(current_state)
                pop_state
              end

              push_state(States::Game)
            end

            stack(fill: true)

            button("EXIT") { close }
          end
          stack(width: 0.33)
        end
      end

      def draw
        previous_state&.draw

        super
      end
    end
  end
end
