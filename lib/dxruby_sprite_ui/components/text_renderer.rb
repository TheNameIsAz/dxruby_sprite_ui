################################################################################
#
# TextRenderer
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################



################################################################################
#
# Context �N���X.
#
# ������̕`��ɗp���� DXRuby::RenderTarget �� DXRuby::Font ��ێ�����\����.
#
# Accessors:
#   - target : DXRuby::RenderTarget �`���� RenderTarget �I�u�W�F�N�g.
#   - font   : DXRuby::Font �`��ɗp���� Font �I�u�W�F�N�g.
#
module DXRuby::SpriteUI

  Context = Struct.new(:target, :font)

end

################################################################################
#
# TextRenderer �N���X.
#
# ������`��R���e�L�X�g�ƕ`��ΏہA���W�����ɕ�����̕`����s��.
#
module DXRuby::SpriteUI::TextRenderer

  ##############################################################################
  #
  # �`����s��.
  #
  # Params:
  #   - x        : x ���W.
  #   - y        : y ���W.
  #   - drawable : draw_params ���\�b�h�����������I�u�W�F�N�g.
  #   - context  : SpriteUI::Context �I�u�W�F�N�g.
  #
  # Todo:
  #   drawable.width �� drawable �o�R�łȂ����@�ŎQ�Ƃ�����@����������.
  #
  def self.draw(x, y, drawable, context)
    text, params = *drawable.draw_params
    target, font = context.target, context.font
    align = text_align(params[:text_align], x, drawable.width, font)
    draw_font = (target or Window).method(params[:aa] ? :draw_font_ex : :draw_font)
    text.each_line.inject(y) do |y, line|
      if params[:text_align] == :fill
        align_fill(draw_font, line, drawable)
      else
        draw_font[align[line], y, line.chomp, font, params]
      end
      y + font.size
    end
  end

  def self.align_fill(draw_font, text, drawable)
    curr = text[0]
    chars = text.each_char.slice_before {|e|
      curr, prev = e, curr
      /\s/ === e or not (e + prev).ascii_only?
    }.reject {|char| char.reject {|c| /\s/ === c }.empty? }.to_a
    if chars.size == 1
      width = drawable.width - font.get_width(text)
      draw_font[x + width / 2, y, text, font, params]
    else
      width = (drawable.width - drawable.padding * 2) - font.get_width(chars.join)
      pad = width / (chars.size - 1)
      chars.inject(x) do |x, char|
        draw_font[x, y, char.join, font, params]
        x + font.get_width(char.join) + pad
      end
    end
  end

  def self.text_align(align, x, width, font)
    case align
    when :center
      -> text { x + (width - font.get_width(text)) / 2 }
    when :right
      -> text { x + (width - font.get_width(text)) }
    else
      -> * { x }
    end
  end

end
