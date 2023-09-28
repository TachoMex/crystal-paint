module Tools
  class Base
    @erasable : Bool
    @canvas : Canvas
    @backup : Image

    def initialize(@canvas, @backup)
      @erasable = false
    end

    def heartbeat
    end

    def on_click(b, e, x, y)
    end

    def on_motion(x, y)
    end

    def reset_canvas
      @canvas.canvas.pixels = Image.new(@backup).pixels
    end

    def make_backup
      @backup = Image.new(@canvas.canvas)
    end

    def render
      @canvas.render(0, 0)
      @canvas.canvas.save_bmp("paint.bmp")
      @backup.save_bmp("backup.bmp")
    end

    def commit
      make_backup
    end
  end
end
