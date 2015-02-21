################################################################################
#
# SpriteUI
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

require 'dxruby'
require 'quincite'

module DXRuby

  ##############################################################################
  #
  # SpriteUI ���W���[��.
  #
  module SpriteUI

    include Quincite

    ############################################################################
    #
    # �r���_�[ DSL �����s���� UI �c���[���\�z����.
    #
    def self.build(&proc)
      UI.build(UI::ContainerBox, &proc)
    end

    ############################################################################
    #
    # SpriteUI �Ƀ��W���[�������蓖�Ă�.
    #
    def self.equip(mod)
      Base.__send__(:include, const_get(mod))
    end

    ############################################################################
    #
    # ColorUtils ���W���[��
    #
    module ColorUtils

      ##########################################################################
      #
      # ������F�z��𐶐�����.
      #
      # Params:
      #   - color :
      #
      def self.make_color(color)
        case color
        when Array
          color
        when Fixnum
          [color >> 16 & 0xff,
           color >> 8 & 0xff,
           color & 0xff]
        when /^#[0-9a-fA-F]{6}$/
          [color[1..2].hex,
           color[3..4].hex,
           color[5..6].hex]
        else
          nil
        end
      end

    end

    ############################################################################
    #
    # StyleSet �N���X.
    #
    class StyleSet

      # 
      #
      attr_reader :bg

      # 
      #
      attr_accessor :border_width, :border_color
      attr_accessor :margin, :padding
      attr_accessor :width, :height
      attr_accessor :position, :top, :left
      attr_accessor :visible

      ##########################################################################
      #
      # ������.
      #
      def initialize
        @margin = 0
        @padding = 0
        @bg = nil
        @border_width = 0
        @border_color = [0, 0, 0, 0]
        @width = nil
        @height = nil
        @position = :relative
        @top = 0
        @left = 0
        @visible = true
      end

      ##########################################################################
      #
      # �w�i�F��ݒ肷��.
      #
      def bgcolor=(bgcolor)
        bgcolor = ColorUtils.make_color(bgcolor)
        if bgcolor
          @bg = Image.new(1, 1, bgcolor)
        else
          @bg = nil
        end
      end

      ##########################################################################
      #
      # �g����ݒ肷��.
      #
      def border=(border)
        case border
        when Hash
          @border_width = border[:width] || 1
          @border_color = ColorUtils.make_color(border[:color]) || [255, 255, 255]
        else
          @border_width = nil
          @border_color = nil
        end
      end

      ##########################################################################
      #
      # ����Ԃ��擾����.
      #
      # Returns:
      # 
      #
      def visible?
        @visible
      end

    end

    ############################################################################
    #
    # Base �N���X
    #
    class Base < Sprite

      include SpriteUI
      include UI::Control

      extend Forwardable

      # 
      #
      attr_accessor :id

      # 
      #
      attr_reader :style

      # 
      #
      def_delegators :@style, :position
      def_delegators :@style, :top, :left
      def_delegators :@style, :padding
      def_delegators :@style, :visible?

      ##########################################################################
      #
      # ������.
      #
      def initialize(id='', *args)
        super(0, 0)
        self.id = id
        self.collision = [0, 0]
        @style = StyleSet.new
        init_control
      end

      ##########################################################################
      #
      # �w�肳�ꂽ���O�̃X�^�C�������݂��邩������s��.
      #
      # Params:
      #   - name :
      #
      # Returns:
      #   
      #
      def style_include?(name)
        @style.respond_to?("#{name}=")
      end

      ##########################################################################
      #
      # �X�^�C����ݒ肷��.
      #
      # Params:
      #   - name :
      #   - args :
      #
      def style_set(name, args)
        @style.__send__("#{name}=", args)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̕����擾����.
      #
      def width
        if @width
          @width
        elsif @computed_width
          @computed_width
        else
          content_width
        end
      end

      ##########################################################################
      #
      # ���e���ɉ����������擾����.
      #
      def content_width
        if image
          image.width
        else
          0
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍������擾����.
      #
      def height
        if @height
          @height
        elsif @computed_height
          @computed_height
        else
          content_height
        end
      end

      ##########################################################################
      #
      # ���e���ɉ������������擾����.
      #
      def content_height
        if image
          image.height
        else
          0
        end
      end

      ##########################################################################
      #
      # �z�u��̃R���|�[�l���g�̕����擾����.
      #
      def layout_width
        case position
        when :absolute
          0
        else
          width + margin * 2
        end
      end

      ##########################################################################
      #
      # �z�u��̃R���|�[�l���g�̍������擾����.
      #
      def layout_height
        case position
        when :absolute
          0
        else
          height + margin * 2
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̊O���̗]�����擾����.
      #
      def margin
        case position
        when :absolute
          0
        else
          @style.margin
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̕`��.
      #
      def draw
        if visible?
          draw_bg if @style.bg
          draw_image(x + padding, y + padding) if image
          draw_border if @style.border_width and @style.border_color
        end
      end

      ##########################################################################
      #
      # �w�i��`�悷��.
      #
      def draw_bg
        (target or Window).draw_scale(x, y, @style.bg, width, height, 0, 0)
      end

      ##########################################################################
      #
      # �g����`�悷��.
      #
      def draw_border
        draw_box(x, y, x + width, y + height, @style.border_width, @style.border_color)
      end

      ##########################################################################
      #
      # �摜��`�悷��.
      #
      def draw_image(x, y)
        (target or Window).draw(x, y, image)
      end

      ##########################################################################
      #
      # ������`�悷��.
      #
      def draw_line(x0, y0, x1, y1, width, color)
        if width == 1
          (target or Window).draw_line(x0, y0, x1 + width - 1, y1 + width - 1, color)
        else
          (target or Window).draw_box_fill(x0, y0, x1 + width - 1, y1 + width - 1, color)
        end
      end

      ##########################################################################
      #
      # ��`�̋��E����`�悷��.
      #
      def draw_box(x0, y0, x1, y1, width, color)
        draw_line(x0, y0, x1 - width, y0, width, color)
        draw_line(x0, y0, x0, y1 - width, width, color)
        draw_line(x0, y1 - width, x1 - width, y1 - width, width, color)
        draw_line(x1 - width, y0, x1 - width, y1 - width, width, color)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍X�V.
      #
      def update
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̔z�u.
      #
      def layout(ox=0, oy=0)
        resize(width || Window.width, height || Window.height, 0)
        move(ox, oy)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍��W�̍X�V.
      #
      def move(to_x, to_y)
        self.x = to_x + left
        self.y = to_y + top
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̗̈�̍X�V.
      #
      def resize(width, height, margin)
        case @style.width
        when Integer
          @width = @style.width
        when Float
          @width = width * @style.width
        when :full
          @width = width - [margin, self.margin].max * 2
        else
          @width = nil
        end
        case @style.height
        when Integer
          @height = @style.height
        when Float
          @height = height * @style.height
        when :full
          @height = height - [margin, self.margin].max * 2
        else
          @height = nil
        end
      end

      ##########################################################################
      #
      # �ڐG����̈�̍X�V.
      #
      def update_collision
        self.collision = [0, 0, self.width, self.height]
      end

    end

    ############################################################################
    #
    # Container �N���X.
    #
    class Container < Base

      include UI::Container

      ##########################################################################
      #
      # ������.
      #
      def initialize(*args)
        super
        init_container
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̕`��.
      #
      def draw
        super
        components.each(&:draw) if visible?
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍X�V.
      #
      def update
        super
        components.each(&:update)
      end

    end
  end
end
