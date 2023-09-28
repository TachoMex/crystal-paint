require "./base"

module Tools
  class Line < Base
    @active : Bool
    @last_x : Int32
    @last_y : Int32

    def initialize(canvas, backup)
      super(canvas, backup)
      @active = false
      @last_x = 0
      @last_y = 0
    end

    def draw(x, y)
      @canvas.line(@last_x, @last_y, x, y)
    end

    def on_click(b, e, x, y)
      if b == LibGLUT::LEFT_BUTTON
        if e == LibGLUT::UP
          @active = false
          make_backup
        elsif e == LibGLUT::DOWN
          @active = true
          @last_x = x
          @last_y = y
        end
      end
    end

    def on_motion(x, y)
      if @active
        reset_canvas
        draw(x, y)
      end
    end
  end
end
