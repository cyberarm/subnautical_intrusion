module SubnauticalIntrusion
  class PlayerEntity < Entity
    attr_reader :radius

    def initialize(**args)
      super

      pp args
      @radius = args[:radius]
    end

    def draw
      super

      Gosu.draw_arc(@position.x, @position.y, @radius, 1.0, 36, 1, 0x44_00ff00, @position.z)
    end

    def update(dt, input)
      super

      @position.x += @velocity.x
      @position.y -= @velocity.y

      @velocity *= @drag
      @velocity.x = 0 if @velocity.x.abs < MIN_VELOCITY
      @velocity.y = 0 if @velocity.y.abs < MIN_VELOCITY

      @velocity.x += @speed * dt if input.right?
      @velocity.x -= @speed * dt if input.left?
      @velocity.y += @speed * dt if input.up?
      @velocity.y -= @speed * dt if input.down?
    end
  end
end
