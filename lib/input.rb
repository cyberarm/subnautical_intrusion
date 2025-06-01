module SubnauticalIntrusion
  class Input
    attr_accessor :up, :down, :left, :right

    def initialize
      @up = false
      @down = false
      @left = false
      @right = false
    end

    def up?
      @up
    end

    def down?
      @down
    end

    def left?
      @left
    end

    def right?
      @right
    end

    def ==(other)
      if other.is_a?(Input)
        up == other.up && down == other.down && left == other.left && right == other.right
      elsif other == nil
        !up && !down && !left && !right
      else
        super
      end
    end
  end
end