module SubnauticalIntrusion
  module States
    class Game < CyberarmEngine::GuiState
      def setup
        @offset = CyberarmEngine::Vector.new(0, 0)
        @scale = (window.width.to_f / DESIGN_RESOLUTION_WIDTH)

        @land = get_image("#{ROOT_PATH}/media/land.png")

        @entities = [
          SonarEntity.new(x: 128, y: 128 + 0, z: 0, sprite: get_image("#{ROOT_PATH}/media/ships/aircraft_carrier.png", retro: true), color: Gosu::Color::RED),
          SonarEntity.new(x: 128, y: 128 + 32, z: 0, sprite: get_image("#{ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED),
          SonarEntity.new(x: 128, y: 128 + 64, z: 0, sprite: get_image("#{ROOT_PATH}/media/ships/cruiser.png", retro: true), color: Gosu::Color::RED),
          SonarEntity.new(x: 128, y: 128 + 96, z: 0, sprite: get_image("#{ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED),

          @submarine = Entity.new(x: 32, y: 96, z: 0, sprite: get_image("#{ROOT_PATH}/media/ships/submarine.png", retro: true), color: Gosu::Color::GREEN)
        ]


        flow(width: 1.0, height: 128, padding: 8) do
          title "Hey, there. Got boat?", static: true
        end
      end

      def draw
        # Water plane
        Gosu.draw_rect(0, 0, window.width, window.height, 0xff_1a5fb4)

        Gosu.scale(@scale, @scale, window.width / 2, window.height / 2) do
          Gosu.translate(-@offset.x, -@offset.y) do
            @land.draw(0, 0, 0)

            # @submarine.draw
            @entities.each(&:draw)
          end
        end

        super
      end

      def update
        @scale = (window.width.to_f / DESIGN_RESOLUTION_WIDTH)

        center_around(@submarine)
      end

      def center_around(entity, lag = CyberarmEngine::Vector.new(0.95, 0.95))
        @offset.x += ((entity.position.x - window.width  / 2) - @offset.x) * (1.0 - lag.x)
        @offset.y += ((entity.position.y - window.height / 2) - @offset.y) * (1.0 - lag.y)
      end
    end
  end
end
