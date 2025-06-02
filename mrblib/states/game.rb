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

      LAND_BLOB = []

      def setup
        # Do this at runtime...
        @ROOT_PATH = RUBY_ENGINE == "mruby" ? "." : File.expand_path("../../..", __FILE__)

        self.show_cursor = DEBUG_MODE
        theme(THEME)

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

        @land = get_image("#{@ROOT_PATH}/media/land.png")
        # LAND_BLOB = @land.to_blob

        # Workaround mruby choking on strings with null bytes on linux (even under wine)
        if LAND_BLOB.empty?
          if File.exist?("#{@ROOT_PATH}/media/land.dat")
            File.open("#{@ROOT_PATH}/media/land.dat", "r") do |f|
              f.read.chars.each do |c|
                break unless c != "1" || c != "0"

                LAND_BLOB << c.to_i
              end
            end
          else
            raise "Failed." if RUBY_ENGINE == "mruby"

            blob = @land.to_blob
            stride = 4

            @land.height.times do |y|
              @land.width.times do |x|
                index = (x * stride) + @land.width * (y * stride)
                rgba = blob[index...(index + stride)]

                LAND_BLOB << ((rgba[3].bytes[0] > 0) ? 1 : 0)
              end
            end

            File.open("#{@ROOT_PATH}/media/land.dat", "w") do |f|
              f.puts("#{LAND_BLOB.join('')}")
              f.puts
            end
          end
        end

        @entities = [
          @submarine = PlayerEntity.new(x: 320, y: 1764, z: 0, sprite: get_image("#{@ROOT_PATH}/media/ships/submarine.png", retro: true), color: Gosu::Color::GREEN, drag: 0.99, speed: 1, radius: 8)
        ]

        # Spawn patrolling ships
        ### Patrolling Bean Island
        @entities << SonarEntity.new(x: 848, y: 1520, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(848, 1520),
          CyberarmEngine::Vector.new(936, 1416),
          CyberarmEngine::Vector.new(872, 1320),
          CyberarmEngine::Vector.new(744, 1352),
          CyberarmEngine::Vector.new(648, 1448),
          CyberarmEngine::Vector.new(616, 1512),
          CyberarmEngine::Vector.new(648, 1576),
          CyberarmEngine::Vector.new(776, 1576)
        ])
        @entities << SonarEntity.new(x: 936, y: 1416, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(936, 1416),
          CyberarmEngine::Vector.new(872, 1320),
          CyberarmEngine::Vector.new(744, 1352),
          CyberarmEngine::Vector.new(648, 1448),
          CyberarmEngine::Vector.new(616, 1512),
          CyberarmEngine::Vector.new(648, 1576),
          CyberarmEngine::Vector.new(776, 1576),
          CyberarmEngine::Vector.new(848, 1520),
        ])

        ### Patrolling Peanut Island
        @entities << SonarEntity.new(x: 872, y: 776, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(872, 776),
          CyberarmEngine::Vector.new(968, 744),
          CyberarmEngine::Vector.new(1000, 648),
          CyberarmEngine::Vector.new(1000, 584),
          CyberarmEngine::Vector.new(936, 552),
          CyberarmEngine::Vector.new(808, 616),
          CyberarmEngine::Vector.new(680, 680),
          CyberarmEngine::Vector.new(616, 712),
          CyberarmEngine::Vector.new(584, 776),
          CyberarmEngine::Vector.new(584, 840),
          CyberarmEngine::Vector.new(648, 904),
          CyberarmEngine::Vector.new(744, 904),
          CyberarmEngine::Vector.new(840, 872),
        ])
        @entities << SonarEntity.new(x: 968, y: 744, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/cruiser.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(968, 744),
          CyberarmEngine::Vector.new(1000, 648),
          CyberarmEngine::Vector.new(1000, 584),
          CyberarmEngine::Vector.new(936, 552),
          CyberarmEngine::Vector.new(808, 616),
          CyberarmEngine::Vector.new(680, 680),
          CyberarmEngine::Vector.new(616, 712),
          CyberarmEngine::Vector.new(584, 776),
          CyberarmEngine::Vector.new(584, 840),
          CyberarmEngine::Vector.new(648, 904),
          CyberarmEngine::Vector.new(744, 904),
          CyberarmEngine::Vector.new(840, 872),
          CyberarmEngine::Vector.new(872, 776),
        ])

        ### Carrier Group
        @entities << SonarEntity.new(x: 1480, y: 680, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/aircraft_carrier.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1480, 680),
          CyberarmEngine::Vector.new(1544, 808),
          CyberarmEngine::Vector.new(1032, 1000),
          CyberarmEngine::Vector.new(488, 1160),
          CyberarmEngine::Vector.new(360, 1096),
          CyberarmEngine::Vector.new(328, 648),
          CyberarmEngine::Vector.new(584, 456),
          CyberarmEngine::Vector.new(1096, 360),
          CyberarmEngine::Vector.new(1256, 584),
        ])
        @entities << SonarEntity.new(x: 1256, y: 584, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1256, 584),
          CyberarmEngine::Vector.new(1480, 680),
          CyberarmEngine::Vector.new(1544, 808),
          CyberarmEngine::Vector.new(1032, 1000),
          CyberarmEngine::Vector.new(488, 1160),
          CyberarmEngine::Vector.new(360, 1096),
          CyberarmEngine::Vector.new(328, 648),
          CyberarmEngine::Vector.new(584, 456),
          CyberarmEngine::Vector.new(1096, 360),
        ])
        @entities << SonarEntity.new(x: 1544, y: 808, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/cruiser.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1544, 808),
          CyberarmEngine::Vector.new(1032, 1000),
          CyberarmEngine::Vector.new(488, 1160),
          CyberarmEngine::Vector.new(360, 1096),
          CyberarmEngine::Vector.new(328, 648),
          CyberarmEngine::Vector.new(584, 456),
          CyberarmEngine::Vector.new(1096, 360),
          CyberarmEngine::Vector.new(1256, 584),
          CyberarmEngine::Vector.new(1480, 680),
        ])

        ### River Patrol
        @entities << SonarEntity.new(x: 1584, y: 656, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1584, 656),
          CyberarmEngine::Vector.new(1712, 624),
          CyberarmEngine::Vector.new(1680, 848),
          CyberarmEngine::Vector.new(1616, 848),
          CyberarmEngine::Vector.new(1648, 752),
        ])
        @entities << SonarEntity.new(x: 1680, y: 848, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1680, 848),
          CyberarmEngine::Vector.new(1616, 848),
          CyberarmEngine::Vector.new(1648, 752),
          CyberarmEngine::Vector.new(1584, 656),
          CyberarmEngine::Vector.new(1712, 624),
        ])

        ### Lower Right Group
        @entities << SonarEntity.new(x: 1520, y: 1840, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1520, 1840),
          CyberarmEngine::Vector.new(1008, 1712),
          CyberarmEngine::Vector.new(1136, 1360),
          CyberarmEngine::Vector.new(1392, 1456),
        ])
        @entities << SonarEntity.new(x: 1136, y: 1360, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1136, 1360),
          CyberarmEngine::Vector.new(1392, 1456),
          CyberarmEngine::Vector.new(1520, 1840),
          CyberarmEngine::Vector.new(1008, 1712),
        ])
        @entities << SonarEntity.new(x: 1008, y: 1712, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED, patrol_nodes: [
          CyberarmEngine::Vector.new(1008, 1712),
          CyberarmEngine::Vector.new(1136, 1360),
          CyberarmEngine::Vector.new(1392, 1456),
          CyberarmEngine::Vector.new(1520, 1840),
        ])

        ### ----------------------------------- ###

        # Spawn River Guardians
        @entities << SonarEntity.new(x: 1488, y: 624, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED)
        @entities << SonarEntity.new(x: 1520, y: 912, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED)

        # Spawn blockade of river
        @entities << SonarEntity.new(x: 304, y: 242 - 32, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/battleship.png", retro: true), color: Gosu::Color::RED)
        @entities << SonarEntity.new(x: 242, y: 304 - 32, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/aircraft_carrier.png", retro: true), color: Gosu::Color::RED)
        @entities << SonarEntity.new(x: 368, y: 304 - 32, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/patrol_boat.png", retro: true), color: Gosu::Color::RED)

        # Spawn blockade of open ocean (bottom of map)
        ships = %w[patrol_boat battleship cruiser]
        (24 - 9).times do |i|
          @entities << SonarEntity.new(x: 272 + (32 * i * 3), y: 1968, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/#{ships[i % ships.size]}.png", retro: true), color: Gosu::Color::RED)
        end
        (24 - 10).times do |i|
          @entities << SonarEntity.new(x: 272 + 32 + (32 * i * 3), y: 1968 - 64, z: 1, sprite: get_image("#{@ROOT_PATH}/media/ships/#{ships[(i + 1) % ships.size]}.png", retro: true), color: Gosu::Color::RED)
        end

        stack(width: 1.0, height: 1.0, padding: 8, visible: DEBUG_MODE) do
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
        input.up    = UP_KEYS.any?    { |key| Gosu.button_down?(key) }
        input.down  = DOWN_KEYS.any?  { |key| Gosu.button_down?(key) }
        input.left  = LEFT_KEYS.any?  { |key| Gosu.button_down?(key) }
        input.right = RIGHT_KEYS.any? { |key| Gosu.button_down?(key) }

        physics(CyberarmEngine::Window.dt, input)

        center_around(@submarine)

        # FIXME: Clamp offset such that the map is affixed to the edges of the screen
        # width_margin = [(window.width * @scale), @land.width].min - [(window.width * @scale), @land.width].max
        # pp [width_margin, width_margin * @scale, width_margin / @scale, width_margin / 2]
        # @offset.x = width_margin if @offset.x < width_margin
        # @offset.x = @land.width if @offset.x > @land.width

        # Detected by Sonar
        detected = @entities.find do |e|
          next if e == @submarine

          e.entity_in_sonar_range?(@submarine)
        end
        # Beach on land
        beached = mrb_entity_vs_land(@submarine)

        @label.value = "SCALE: #{@scale}, OFFSET X: #{@offset.x.round(1)}, OFFSET Y: #{@offset.y.round(1)}\n\nPOSITION X: #{@submarine.position.x.round(1)}, POSITION Y: #{@submarine.position.y.round(1)}, BEACHED? #{beached}, DETECTED? #{detected != nil}"

        if detected
          push_state(States::GameOver, reason: "Detected by Sonar")
        elsif beached
          push_state(States::GameOver, reason: "Beached on Land")
        end

        if @submarine.position.x >= 2000 && @submarine.position.y >= 192 && @submarine.position.y <= 496
          push_state(States::GameWon, reason: "Escaped the Simulation")
        end
      end

      def button_up(id)
        case id
        when Gosu::KB_ESCAPE
          push_state(States::GameOver, reason: "Simulation aborted by Trainee")
        end
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

      # Mruby doesn't like the way Gosu::Image#to_blob does strings (has null byte(s))
      # and I don't have time to dive into fixing it, so work around it...
      def mrb_entity_vs_land(entity)
        # If out of bounds then beach the vessel and run.
        return true if entity.position.x < 0
        return true if entity.position.y < 0
        return true if entity.position.x > @land.width
        return true if entity.position.y > @land.height

        index = entity.position.x.floor + @land.width * entity.position.y.floor
        LAND_BLOB[index] == 1
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

        rgba_pixel = LAND_BLOB[index...(index + stride)]

        chars = rgba_pixel.chars

        # Something must have gone horribly wrong, beach the vessel and run!
        return true unless chars.size == stride
        # raise "What?" unless chars.size == stride

        # pp [index, chars]

        chars[3].bytes.first > 0
      end

      def simulation_time
        @milliseconds
      end
    end
  end
end
