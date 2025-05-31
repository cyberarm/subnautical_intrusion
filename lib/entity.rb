module SubnauticalIntrusion
  class Entity
    attr_reader :position, :sprite, :speed, :drag, :velocity, :last_position

    def initialize(x:, y:, z:, sprite:, speed: 10.0, drag: 0.9, color: Gosu::Color::WHITE, controller: nil, angle: 0)
      @position = CyberarmEngine::Vector.new(x, y, z)
      @sprite = sprite
      @speed = speed
      @drag = drag
      @color = color
      @controller = controller
      @angle = angle

      @velocity = CyberarmEngine::Vector.new(0, 0, 0)
      @last_position = CyberarmEngine::Vector.new(@position.x, @position.y)
    end

    def update(dt)
    end

    def draw
      @sprite.draw_rot(@position.x, @position.y, @position.z, @angle, 0.5, 0.5, 1.0, 1.0, @color)
    end
  end
end
