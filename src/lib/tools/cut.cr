require "./base"

module Tools
  class Cut < Base
    @clipboard : Image?
    @last_x = 0
    @last_y = 0
    @clipboard_x = 0
    @clipboard_y = 0
    @x_pad = 0
    @y_pad = 0
    @clipboard = nil
    @active = false

    def empty_clipboard?
      @clipboard.nil?
    end

    def draw(x, y)
      if empty_clipboard?
        draw_cut_selection(x, y)
      else
        draw_clipboard
      end
    end

    def draw_cut_selection(x, y)
      @canvas.rectangle(Math.min(x, @last_x),
        Math.min(y, @last_y),
        Math.max(x, @last_x) - 1,
        Math.max(y, @last_y) - 1)
    end

    def draw_clipboard
      clipboard = @clipboard
      return if clipboard.nil?
      clipboard.draw_at(@canvas.canvas, @clipboard_x - 1, @clipboard_y - 1)
      @canvas.rectangle(@clipboard_x, @clipboard_y,
        @clipboard_x + clipboard.width - 1,
        @clipboard_y + clipboard.height - 1)
    end

    def fill_clipboard(x, y)
      x_size = (x - @last_x).abs
      y_size = (y - @last_y).abs
      return if (x_size * y_size == 0)
      @clipboard_x = Math.min(x, @last_x)
      @clipboard_y = Math.min(y, @last_y)
      clipboard = @backup.region(@clipboard_x, @clipboard_y, x_size, y_size)
      (0...x_size).each do |i|
        (0...y_size).each do |j|
          @canvas.single_erase(@clipboard_x + i, @clipboard_y + j)
        end
      end
      commit
      draw_clipboard
      clipboard = @clipboard
      return if clipboard.nil?
      clipboard.save_bmp("clipboard.bmp")
    end

    def paste_clipboard
      clipboard = @clipboard
      return if clipboard.nil?
      clipboard.draw_at(@canvas.canvas, @clipboard_x, @clipboard_y)
      commit
    end

    def release_clipboard
      clipboard = nil
    end

    def click_over_clipboard(x, y)
      clipboard = @clipboard
      if clipboard.is_a?(Image)
        width = clipboard.width
        height = clipboard.height
        x >= @clipboard_x && x <= @clipboard_x + width && y >= @clipboard_y && y <= @clipboard_y + height
      else
        false
      end
    end

    def on_click(b, e, x, y)
      x = Math.max(0, Math.min(@canvas.width, x))
      y = Math.max(0, Math.min(@canvas.height, y))
      if (b == LibGLUT::LEFT_BUTTON)
        if (e == LibGLUT::DOWN)
          active = true
          last_x = x
          last_y = y
          if (!empty_clipboard?())
            if (click_over_clipboard(x, y))
              x_pad = x - @clipboard_x
              y_pad = y - @clipboard_y
            else
              paste_clipboard()
              release_clipboard()
            end
          end
        elsif (e == LibGLUT::UP)
          active = false
          if (empty_clipboard?())
            fill_clipboard(x, y)
          end
        end
      end
    end

    def on_motion(x, y)
      if @active
        reset_canvas()
        if (!empty_clipboard?())
          @clipboard_x = x - @x_pad
          @clipboard_y = y - @y_pad
        end
        draw(x, y)
      end
    end
  end
end
