class WorkoutStylesheet < ApplicationStylesheet

  def setup
    # Add sytlesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
  end

  def background(st)
    st.frame = { l: 0, t: 20, w: 1024, h: 748 }
    st.image = image.resource('workout-background')
  end

  def calories_burned(st)
    attribute_label st
    st.frame = {l: 15, t: 690, w: 240, h: 75}
  end

  def current_heart_rate(st)
    attribute_label st
    st.frame = {l: 770, t: 690, w: 240, h: 75}
  end

  def current_mets(st)
    attribute_label st
    st.frame = {l: 520, t: 690, w: 240, h: 75}
  end

  def elapsed_seconds(st)
    attribute_label st
    st.frame = {l: 770, t: 130, w: 240, h: 100}
  end

  def strides_per_minute(st)
    attribute_label st
    st.frame = {l: 10, t: 130, w: 750, h: 100}
  end

  def attribute_label(st)
    st.color = color.white
    st.text_alignment = :center
    st.font = font.system(48)
  end
end
