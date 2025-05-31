module SubnauticalIntrusion
  class SonarEntity < Entity
    def initialize(**args)
      super

      @sonar_radius = 64
      @sonar_segments = 48
    end

    def draw
      super

      Gosu.draw_arc(@position.x, @position.y, @sonar_radius * ((Gosu.milliseconds % 1000) / 1000.0), 1.0, @sonar_segments, 1, Gosu::Color::RED, @position.z)
    end
  end
end
