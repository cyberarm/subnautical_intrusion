module SubnauticalIntrusion
  class Entity
    MIN_VELOCITY = 0.0005

    attr_reader :position, :sprite, :speed, :drag, :velocity, :last_position

    def initialize(x:, y:, z:, sprite:, speed: 0.5, drag: 0.99, color: Gosu::Color::WHITE, controller: nil, angle: 0, radius: 8, patrol_nodes: [])
      @position = CyberarmEngine::Vector.new(x, y, z)
      @sprite = sprite
      @speed = speed
      @drag = drag
      @color = color
      @controller = controller
      @angle = angle
      @radius = radius
      @patrol_nodes = patrol_nodes

      @velocity = CyberarmEngine::Vector.new(0, 0, 0)
      @last_position = CyberarmEngine::Vector.new(@position.x, @position.y)
    end

    def update(dt, input)
      @angle = Gosu.angle(@last_position.x, @last_position.y, @position.x, @position.y) - 90.0

      @last_position.x = @position.x
      @last_position.y = @position.y
    end

    def draw
      @sprite.draw_rot(@position.x, @position.y, @position.z, @angle, 0.5, 0.5, 1.0, 1.0, @color)
    end
  end
end
