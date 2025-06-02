module SubnauticalIntrusion
  module States
    class Game < CyberarmEngine::GuiState
      FIXED_TIMESTEP = 1.0 / 120
      FIXED_TIMESTEP_INT_MS = 8
      MAX_TIMESTEP   = 1.0 / 60

      UP_KEYS = [Gosu::KB_W, Gosu::KB_UP, Gosu::GP_UP]
      DOWN_KEYS = [Gosu::KB_S, Gosu::KB_DOWN, Gosu::GP_DOWN]
      LEFT_KEYS = [Gosu::KB_A, Gosu::KB_LEFT, Gosu::GP_LEFT]
      RIGHT_KEYS = [Gosu::KB_D, Gosu::KB_RIGHT, Gosu::GP_RIGHT]

      def setup
        @original_entities = []

        @inputs = []

        @replay = false
        @replay_frame = 0

        @window = CyberarmEngine::Window.instance

        @milliseconds = 0

        @accumulator = 0.0
        @interpolation = 0.0
        @alpha = 1.0

        @offset = CyberarmEngine::Vector.new(0, 0)
        @scale = (window.width.to_f / DESIGN_RESOLUTION_WIDTH)

        @land = get_image("#{ROOT_PATH}/media/land.png")
        @land_blob = @land.to_blob

        @entities = [
          @submarine = PlayerEntity.new(x: 320, y: 1764, z: 0, sprite: get_image("#{ROOT_PATH}/media/ships/submarine.png", retro: true), color: Gosu::Color::GREEN, drag: 0.99, speed: 1, radius: 8)
        ]

        # Spawn patrolling ships
        @entities << SonarEntity.new(x: 848, y: 1520, z: 1, sprite: get_image("#{ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(848, 1520),
          CyberarmEngine::Vector.new(936, 1416),
          CyberarmEngine::Vector.new(872, 1320),
          CyberarmEngine::Vector.new(744, 1352),
          CyberarmEngine::Vector.new(648, 1448),
          CyberarmEngine::Vector.new(616, 1512),
          CyberarmEngine::Vector.new(648, 1576),
          CyberarmEngine::Vector.new(776, 1576)
        ])

        # Spawn blockade of river
        @entities << SonarEntity.new(x: 304, y: 242 - 32, z: 1, sprite: get_image("#{ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED)
        @entities << SonarEntity.new(x: 242, y: 304 - 32, z: 1, sprite: get_image("#{ROOT_PATH}/media/ships/aircraft_carrier.png", retro: true), color: Gosu::Color::RED)
        @entities << SonarEntity.new(x: 368, y: 304 - 32, z: 1, sprite: get_image("#{ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED)

        # Spawn blockade of open ocean (bottom of map)
        ships = %w[patrol_boat battleship cruiser]
        (24 - 9).times do |i|
          @entities << SonarEntity.new(x: 272 + (32 * i * 3), y: 1968, z: 1, sprite: get_image("#{ROOT_PATH}/media/ships/#{ships[i % ships.size]}.png", retro: true), color: Gosu::Color::RED)
        end
        (24 - 10).times do |i|
          @entities << SonarEntity.new(x: 272 + 32 + (32 * i * 3), y: 1968 - 64, z: 1, sprite: get_image("#{ROOT_PATH}/media/ships/#{ships[(i + 1) % ships.size]}.png", retro: true), color: Gosu::Color::RED)
        end

        stack(width: 1.0, height: 1.0, padding: 8) do
          title "Hey, there. Got boat?", static: true
          @label = title "OFFSET X: -, OFFSET Y: -", static: true
        end
      end

      def draw
        # Water plane
        Gosu.draw_rect(0, 0, window.width, window.height, 0xff_1a5fb4)

        Gosu.scale(@scale, @scale, window.width / 2, window.height / 2) do
          Gosu.translate(-@offset.x, -@offset.y) do
            @land.draw(0, 0, 0)

            @entities.each(&:draw)
          end
        end

        super
      end

      def update
        super

        @scale = (window.width.to_f / DESIGN_RESOLUTION_WIDTH)

        input = Input.new
        input.up  = UP_KEYS.any?  { |key| Gosu.button_down?(key) }
        input.down  = DOWN_KEYS.any?  { |key| Gosu.button_down?(key) }
        input.left  = LEFT_KEYS.any?  { |key| Gosu.button_down?(key) }
        input.right = RIGHT_KEYS.any? { |key| Gosu.button_down?(key) }

        physics(CyberarmEngine::Window.dt, input)

        center_around(@submarine)

        # FIXME: Clamp offset such that the map is affixed to the edges of the screen
        width_margin = [(window.width * @scale), @land.width].min - [(window.width * @scale), @land.width].max
        pp [width_margin, width_margin * @scale, width_margin / @scale, width_margin / 2]
        @offset.x = width_margin if @offset.x < width_margin
        # @offset.x = @land.width if @offset.x > @land.width

        @label.value = "SCALE: #{@scale}, OFFSET X: #{@offset.x.round(1)}, OFFSET Y: #{@offset.y.round(1)}\n\nPOSITION X: #{@submarine.position.x.round(1)}, POSITION Y: #{@submarine.position.y.round(1)}, BEACHED? #{entity_vs_land(@submarine)}"
      end

      def physics(dt, input)
        dt = MAX_TIMESTEP if dt > MAX_TIMESTEP
        @accumulator += dt

        while @accumulator >= FIXED_TIMESTEP
          @accumulator -= FIXED_TIMESTEP

          if replay?
            input = @inputs[@replay_frame]
            return unless input
            # input ||= Input.new

            # puts "REPLAY: #{@replay_frame}: #{input}"
            @replay_frame += 1
          else
            @inputs << input != @inputs.last ? input : nil
          end

          @alpha = @accumulator / FIXED_TIMESTEP

          @milliseconds += FIXED_TIMESTEP_INT_MS
          @entities.each { |e| e.update(FIXED_TIMESTEP, input) }
        end
      end

      def replay?
        @replay
      end

      def replay!
        # TODO
      end

      def center_around(entity, lag = CyberarmEngine::Vector.new(0.9, 0.9))
        @offset.x += ((entity.position.x - window.width  / 2) - @offset.x) * (1.0 - lag.x)
        @offset.y += ((entity.position.y - window.height / 2) - @offset.y) * (1.0 - lag.y)
      end

      def entity_vs_land(entity)
        # If out of bounds then beach the vessel and run.
        return true if entity.position.x < 0
        return true if entity.position.y < 0
        return true if entity.position.x > @land.width
        return true if entity.position.y > @land.height

        stride = 4

        index = (entity.position.x.floor * stride) + @land.width * (entity.position.y.floor * stride)
        return true if index.negative? # Out of bounds

        rgba_pixel = @land_blob[index...(index + stride)]

        chars = rgba_pixel.chars

        # Something must have gone horribly wrong, beach the vessel and run!
        return true unless chars.size == stride
        # raise "What?" unless chars.size == stride

        # pp [index, chars]

        chars[3].bytes.first > 0
      end
    end
  end
end
