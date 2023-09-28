require "./base"

module Tools
  class Filler < Base
    def on_click(b, e, x, y)
      if (b == LibGLUT::LEFT_BUTTON)
        if (e == LibGLUT::DOWN)
          @canvas.fill(x, y)
          commit()
        end
      end
    end
  end
end
